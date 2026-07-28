# RV32I Pipelined Processor Core

32-bit 5-stage pipelined RISC-V CPU implementing the **RV32I** unprivileged integer ISA.

| Stage | Name | Role |
|-------|------|------|
| IF | Instruction Fetch | PC + instruction memory read |
| ID | Instruction Decode | Regfile read, immediate gen, control decode |
| EX | Execute | ALU, branch/jump target, forwarding muxes |
| MEM | Memory | Data memory / MMIO access |
| WB | Write-Back | Regfile write |

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
