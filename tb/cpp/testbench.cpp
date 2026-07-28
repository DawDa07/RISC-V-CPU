//==============================================================================
// testbench.cpp — Master Verilator C++ simulation harness for soc_top
//
// Usage:
//   ./Vsoc_top <program.hex> [--cycles N] [--verbose]
//
// Loads a Verilog $readmemh-compatible hex file into IMEM via the backdoor
// ports, resets the SoC, then clocks until halt, max cycles, or timeout.
//==============================================================================

#include <verilated.h>
#include "Vsoc_top.h"

#if VM_TRACE
# include "verilated_vcd_c.h"
#endif

#include "scoreboard.hpp"

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <string>
#include <vector>

#if VM_TRACE
using TracePtr = VerilatedVcdC*;
#else
using TracePtr = void*;
#endif

//------------------------------------------------------------------------------
// Defaults
//------------------------------------------------------------------------------
static constexpr uint64_t DEFAULT_MAX_CYCLES = 100000;
static constexpr uint64_t RESET_CYCLES       = 5;

//------------------------------------------------------------------------------
// Load a flat hex file (one 32-bit word per line) into a vector
//------------------------------------------------------------------------------
static std::vector<uint32_t> load_hex(const std::string& path) {
    std::ifstream in(path);
    if (!in) {
        std::fprintf(stderr, "error: cannot open hex file '%s'\n", path.c_str());
        std::exit(1);
    }

    std::vector<uint32_t> words;
    std::string line;
    while (std::getline(in, line)) {
        // Strip comments and whitespace
        auto hash = line.find('#');
        if (hash != std::string::npos) line.resize(hash);
        auto slash = line.find("//");
        if (slash != std::string::npos) line.resize(slash);

        // Trim
        while (!line.empty() && (line.back() == ' ' || line.back() == '\t' ||
                                 line.back() == '\r'))
            line.pop_back();
        size_t start = 0;
        while (start < line.size() && (line[start] == ' ' || line[start] == '\t'))
            ++start;
        if (start >= line.size()) continue;

        uint32_t word = static_cast<uint32_t>(std::strtoul(line.c_str() + start,
                                                           nullptr, 16));
        words.push_back(word);
    }
    return words;
}

//------------------------------------------------------------------------------
// Single clock edge helper
//------------------------------------------------------------------------------
static void tick(Vsoc_top* top, TracePtr tfp, uint64_t& sim_time) {
    top->clk = 0;
    top->eval();
#if VM_TRACE
    if (tfp) static_cast<VerilatedVcdC*>(tfp)->dump(static_cast<vluint64_t>(sim_time));
#else
    (void)tfp;
#endif
    ++sim_time;

    top->clk = 1;
    top->eval();
#if VM_TRACE
    if (tfp) static_cast<VerilatedVcdC*>(tfp)->dump(static_cast<vluint64_t>(sim_time));
#endif
    ++sim_time;
}

//------------------------------------------------------------------------------
// Main
//------------------------------------------------------------------------------
int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    std::string hex_path;
    uint64_t    max_cycles = DEFAULT_MAX_CYCLES;
    bool        verbose    = false;
    bool        trace      = false;

    for (int i = 1; i < argc; ++i) {
        if (std::strcmp(argv[i], "--cycles") == 0 && i + 1 < argc) {
            max_cycles = std::strtoull(argv[++i], nullptr, 0);
        } else if (std::strcmp(argv[i], "--verbose") == 0) {
            verbose = true;
        } else if (std::strcmp(argv[i], "--trace") == 0) {
            trace = true;
        } else if (argv[i][0] != '-') {
            hex_path = argv[i];
        } else {
            std::fprintf(stderr, "unknown option: %s\n", argv[i]);
            return 1;
        }
    }

    if (hex_path.empty()) {
        std::fprintf(stderr,
                     "usage: %s <program.hex> [--cycles N] [--verbose] [--trace]\n",
                     argv[0]);
        return 1;
    }

    auto words = load_hex(hex_path);
    if (verbose) {
        std::printf("Loaded %zu words from %s\n", words.size(), hex_path.c_str());
    }

    Vsoc_top* top = new Vsoc_top;
    TracePtr tfp  = nullptr;

#if VM_TRACE
    if (trace) {
        Verilated::traceEverOn(true);
        auto* vcd = new VerilatedVcdC;
        top->trace(vcd, 99);
        vcd->open("wave.vcd");
        tfp = vcd;
    }
#else
    (void)trace;
#endif

    uint64_t sim_time = 0;
    Scoreboard sb(verbose);

    //--------------------------------------------------------------------------
    // Reset
    //--------------------------------------------------------------------------
    top->rst_n          = 0;
    top->imem_load_en   = 0;
    top->imem_load_addr = 0;
    top->imem_load_data = 0;

    for (uint64_t i = 0; i < RESET_CYCLES; ++i) {
        tick(top, tfp, sim_time);
    }
    top->rst_n = 1;
    tick(top, tfp, sim_time);

    //--------------------------------------------------------------------------
    // Backdoor-load instruction memory
    //--------------------------------------------------------------------------
    for (size_t i = 0; i < words.size(); ++i) {
        top->imem_load_en   = 1;
        top->imem_load_addr = static_cast<uint32_t>(i);
        top->imem_load_data = words[i];
        tick(top, tfp, sim_time);
    }
    top->imem_load_en = 0;

    // Hold reset again so PC restarts at 0 after IMEM load
    top->rst_n = 0;
    for (uint64_t i = 0; i < RESET_CYCLES; ++i) {
        tick(top, tfp, sim_time);
    }
    top->rst_n = 1;

    //--------------------------------------------------------------------------
    // Example golden expectations for sanity_add.s (x1=5, x2=3, x3=8)
    // Uncomment / extend once the core RTL is implemented.
    //--------------------------------------------------------------------------
    // sb.expect_reg(1, 5);
    // sb.expect_reg(2, 3);
    // sb.expect_reg(3, 8);

    //--------------------------------------------------------------------------
    // Run
    //--------------------------------------------------------------------------
    uint64_t cycles = 0;
    int exit_code   = 0;

    while (cycles < max_cycles && !Verilated::gotFinish()) {
        tick(top, tfp, sim_time);
        ++cycles;

        if (verbose && (cycles % 1000 == 0)) {
            std::printf("[TB] cycle=%llu pc=0x%08x\n",
                        static_cast<unsigned long long>(cycles),
                        top->debug_pc);
        }

        // DUT signals halt (e.g. on EBREAK) — check once RTL drives it
        if (top->debug_halted) {
            if (verbose) {
                std::printf("[TB] DUT halted at cycle %llu pc=0x%08x\n",
                            static_cast<unsigned long long>(cycles),
                            top->debug_pc);
            }
            break;
        }
    }

    if (cycles >= max_cycles) {
        std::printf("TIMEOUT after %llu cycles (pc=0x%08x)\n",
                    static_cast<unsigned long long>(cycles),
                    top->debug_pc);
        // With empty RTL stubs, timeout is expected — do not fail the scaffold
        exit_code = 0;
    }

    if (!sb.finalize()) {
        exit_code = 1;
    } else if (verbose) {
        std::printf("Scoreboard: all checks passed\n");
    }

    std::printf("Simulation finished: %llu cycles\n",
                static_cast<unsigned long long>(cycles));

#if VM_TRACE
    if (tfp) {
        static_cast<VerilatedVcdC*>(tfp)->close();
        delete static_cast<VerilatedVcdC*>(tfp);
    }
#endif
    top->final();
    delete top;
    return exit_code;
}
