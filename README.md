# RV32I Pipelined Processor Core

32-bit 5-stage pipelined RISC-V CPU implementing the **RV32I** unprivileged integer ISA.

| Stage | Name | Role |
|-------|------|------|
| IF | Instruction Fetch | PC + instruction memory read |
| ID | Instruction Decode | Regfile read, immediate gen, control decode |
| EX | Execute | ALU, branch/jump target, forwarding muxes |
| MEM | Memory | Data memory / MMIO access |
| WB | Write-Back | Regfile write |

Hazard detection (stalls/bubbles) and forwarding (bypassing) units are first-class modules in the datapath.

> **Learning project:** RTL under `rtl/core/` and `rtl/memory/` ships as **port-only stubs**. You hand-code the bodies. Infrastructure (Makefile, Verilator TB, linker, asm templates) is fully implemented.

---

## Repository Layout

```text
.
├── .vscode/           Editor lint + Make/Verilator tasks
├── rtl/
│   ├── core/          CPU datapath & control (stubs — implement these)
│   ├── memory/        IMEM, DMEM, UART TX (stubs — implement these)
│   └── soc_top.sv     SoC wiring (CPU + memories + UART) — complete
├── tb/
│   ├── cpp/           Verilator C++ harness + scoreboard
│   └── asm/           Assembly tests + bare-metal linker script
├── syn/               Yosys synthesis script
├── Makefile
└── README.md
```

### Address map (`soc_top`)

| Range | Device |
|-------|--------|
| `0x0000_0000` – `0x0000_FFFF` | Unified instruction / data RAM (64 KiB) |
| `0x1000_0000` – `0x1000_000F` | UART TX (`DATA` @ +0x0, `STATUS` @ +0x4) |

---

## Prerequisites

| Tool | Purpose | Install hint |
|------|---------|--------------|
| [Verilator](https://verilator.org/) ≥ 5.x | RTL lint + C++ simulation | `brew install verilator` |
| RISC-V GCC (optional) | Assemble tests | `brew install riscv-gnu-toolchain` or similar |
| [Yosys](https://yosyshq.net/yosys/) (optional) | Open-source synthesis | `brew install yosys` |
| Make, C++17 compiler | Build harness | Xcode CLT / `build-essential` |

If you do not have a RISC-V toolchain, use `make asm-fallback` to emit a hand-encoded `sanity_add.hex`.

---

## Quick Start

```bash
# 1. Build the Verilator simulation executable
make sim

# 2. Produce a program image
make asm                 # needs riscv64-unknown-elf-*
# — or —
make asm-fallback        # no toolchain required

# 3. Run the smoke test
make run TEST=sanity_add

# Optional: dump wave.vcd
make run-trace TEST=sanity_add
```

### Useful Make targets

| Target | Description |
|--------|-------------|
| `make sim` | Build `build/sim/Vsoc_top` |
| `make run` | Simulate `TEST` (default `sanity_add`) |
| `make run-trace` | Same + VCD waveform |
| `make asm` | Assemble `tb/asm/*.s` → `build/hex/*.hex` |
| `make lint` | Verilator `--lint-only` |
| `make synth` | Yosys synthesis → `build/synth/` |
| `make clean` | Remove `build/` and `wave.vcd` |

VS Code / Cursor: use **Terminal → Run Task…** for the same targets (see `.vscode/tasks.json`).

---

## Implementation Guide (hand-code order)

Suggested order for filling in the `// TODO: Hand-code implementation here` bodies:

1. **`pc_reg`** → **`regfile`** → **`imm_gen`** → **`alu`**
2. **`control_unit`** (opcode → control signals)
3. Pipeline registers: **`if_id_reg`**, **`id_ex_reg`**, **`ex_mem_reg`**, **`mem_wb_reg`**
4. **`forwarding`** then **`hazard_unit`**
5. Wire everything in **`cpu_core`**
6. Memory models: **`imem`**, **`dmem`**, then **`uart_tx`**

Coding conventions (already used in stubs):

- SystemVerilog `.sv` with `logic`
- `always_ff @(posedge clk or negedge rst_n)` for sequential
- `always_comb` for combinational
- Active-low async reset `rst_n`

### Sanity test expected behavior

`tb/asm/sanity_add.s` should leave:

- `x1 = 5`, `x2 = 3`, `x3 = 8`
- word `8` stored at DMEM address `0x100`
- optional UART bytes `'O'`, `'K'`
- `ebreak` asserting `debug_halted`

Uncomment the `sb.expect_reg(...)` lines in `tb/cpp/testbench.cpp` once write-back is observable.

---

## Module Port Quick Reference

| Module | Responsibility |
|--------|----------------|
| `pc_reg` | Program counter with stall |
| `if_id_reg` / `id_ex_reg` / `ex_mem_reg` / `mem_wb_reg` | Pipeline stage boundaries |
| `regfile` | 32×32 dual-read, sync-write; `x0` = 0 |
| `imm_gen` | I/S/B/U/J immediate extract + sign-extend |
| `alu` | ADD/SUB/AND/OR/XOR/shifts/SLT(U) + zero |
| `control_unit` | Main decoder + ALU control |
| `hazard_unit` | Load-use stalls, control-hazard flushes |
| `forwarding` | EX/MEM and MEM/WB bypass selects |
| `cpu_core` | Core top: instantiates datapath + control |
| `imem` / `dmem` | SRAM models (+ IMEM load backdoor) |
| `uart_tx` | Memory-mapped 8N1 transmitter |
| `soc_top` | Chip top (implemented) |

---

## License

Educational / personal use. Add a license file if you publish the completed core.
