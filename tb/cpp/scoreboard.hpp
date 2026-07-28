//==============================================================================
// scoreboard.hpp — Reference checking boilerplate for RV32I simulation
//==============================================================================
#pragma once

#include <cstdint>
#include <cstdio>
#include <string>
#include <vector>
#include <unordered_map>

//------------------------------------------------------------------------------
// Expected write-back event recorded by a golden model or test annotation
//------------------------------------------------------------------------------
struct WbEvent {
    uint32_t cycle;
    uint32_t pc;
    uint32_t rd;       // destination register (0 = no write / x0)
    uint32_t value;    // expected value written to rd
};

//------------------------------------------------------------------------------
// Lightweight scoreboard: compares DUT write-backs against expected events
//------------------------------------------------------------------------------
class Scoreboard {
public:
    explicit Scoreboard(bool verbose = false) : verbose_(verbose), mismatches_(0) {}

    void expect(const WbEvent& e) { expected_.push_back(e); }

    void expect_reg(uint32_t rd, uint32_t value, uint32_t pc = 0) {
        WbEvent e{};
        e.cycle = 0;
        e.pc    = pc;
        e.rd    = rd;
        e.value = value;
        expected_.push_back(e);
        golden_regs_[rd] = value;
    }

    // Call once per retired write-back from the DUT
    void check_wb(uint32_t cycle, uint32_t pc, uint32_t rd, uint32_t value) {
        if (rd == 0) return;  // x0 writes are architecturally ignored

        if (verbose_) {
            std::printf("[SB] cycle=%u pc=0x%08x x%u <= 0x%08x\n",
                        cycle, pc, rd, value);
        }

        observed_regs_[rd] = value;

        // If we have a queued expectation for this rd, compare FIFO-style
        if (!expected_.empty() && expected_.front().rd == rd) {
            const WbEvent& exp = expected_.front();
            if (exp.value != value) {
                std::printf("FAIL: x%u @ pc=0x%08x expected 0x%08x got 0x%08x "
                            "(cycle %u)\n",
                            rd, pc, exp.value, value, cycle);
                ++mismatches_;
            } else if (verbose_) {
                std::printf("PASS: x%u == 0x%08x\n", rd, value);
            }
            expected_.erase(expected_.begin());
        }
    }

    // Final check: compare all golden register values against observed
    bool finalize() const {
        bool ok = (mismatches_ == 0);
        for (const auto& [rd, exp_val] : golden_regs_) {
            auto it = observed_regs_.find(rd);
            if (it == observed_regs_.end()) {
                std::printf("FAIL: x%u never written (expected 0x%08x)\n",
                            rd, exp_val);
                ok = false;
            } else if (it->second != exp_val) {
                std::printf("FAIL: x%u final value 0x%08x != expected 0x%08x\n",
                            rd, it->second, exp_val);
                ok = false;
            }
        }
        if (!expected_.empty()) {
            std::printf("WARN: %zu expected write-back(s) never observed\n",
                        expected_.size());
        }
        return ok && mismatches_ == 0;
    }

    int mismatches() const { return mismatches_; }

private:
    bool verbose_;
    int  mismatches_;
    std::vector<WbEvent> expected_;
    std::unordered_map<uint32_t, uint32_t> golden_regs_;
    std::unordered_map<uint32_t, uint32_t> observed_regs_;
};
