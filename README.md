# RISC-V CPU

A single-cycle RV32I core written in SystemVerilog, built block by block. Every block has its own RTL, a Python reference model, and a cocotb testbench; the top-level `cpu` runs assembled RISC-V programs and checks the architectural state.

![cpu RTL block diagram](cpu/cpu_rtl.png)

## Blocks

| Block | Role |
|-------|------|
| [`pc_reg`](pc_reg/README.md) | Program counter register (async active-low reset) |
| [`pc_plus_4`](pc_plus_4/README.md) | Sequential next-address adder |
| [`next_pc_logic`](next_pc_logic/README.md) | Next-PC mux: PC+4 / branch target / JALR target |
| [`instr_mem_wrapper`](instr_mem_wrapper/README.md) | Instruction memory (behavioral or OpenRAM) |
| [`decoder`](decoder/README.md) | Field extraction + immediate generation |
| [`ctrl`](ctrl/README.md) | Control unit: opcode/funct3/funct7 to datapath controls |
| [`reg_file`](reg_file/README.md) | 32 x 32-bit register file, `x0` hardwired to zero |
| [`alu_in_muxes`](alu_in_muxes/README.md) | ALU operand selection (PC / rs1 / 0, rs2 / imm) |
| [`alu`](alu/README.md) | Arithmetic logic unit + Z/S/O/C flags |
| [`bcu`](bcu/README.md) | Branch control unit: flags to `pc_src` |
| [`sau`](sau/README.md) | Store alignment unit: byte-lane data + write strobes |
| [`data_mem_wrapper`](data_mem_wrapper/README.md) | Data memory (behavioral or OpenRAM) |
| [`lau`](lau/README.md) | Load alignment unit: shift + sign/zero extend |
| [`rf_wb_mux`](rf_wb_mux/README.md) | Write-back mux: ALU / load / PC+4 |
| [`cpu`](cpu/README.md) | Top level wiring all of the above |

Shared enums (`alu_op_e`, `opcode_e`, mux selects) live in [`cpu_sv_package.sv`](cpu_sv_package.sv).

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| Icarus Verilog 12+ | Simulator (`-g2012`) | `brew install icarus-verilog` |
| Python 3 + cocotb 2.x | Testbenches | `pip install cocotb` (this repo was developed with the conda `base` env) |
| riscv64-elf-binutils | Assemble CPU test programs (optional) | `brew install riscv64-elf-binutils` |

The RISC-V toolchain is optional: the assembled `cpu/programs/*.hex` files are committed, so CPU tests run without it.

## Running tests

Each block directory contains a `Makefile` that compiles the RTL and runs its cocotb testbench with Icarus.

```sh
# one block
cd alu && make

# full core (runs every program in cpu/programs)
cd cpu && make

# everything, fail-fast
make test-all

# rebuild test programs from source (needs riscv64-elf-binutils)
make -C cpu/programs

# remove sim_build/ and results.xml everywhere
make clean-all
```

`cd cpu && make` also runs the `programs` target first: it re-assembles any changed `.S` when the toolchain is present, and otherwise falls back to the committed `.hex`.

## CPU test convention

CPU-level tests live in [`cpu/python_stimulus_cpu.py`](cpu/python_stimulus_cpu.py). Each test:

1. Backdoor-loads a program from `cpu/programs/<name>.hex` into instruction memory and zeroes the register file and data memory.
2. Releases reset and clocks the core until the PC stays put for two cycles, i.e. the program has reached its final `j .` spin loop.
3. Compares selected registers, data-memory words, and optionally the spin address against the expected values written next to the test.

Programs are plain GNU assembly (`cpu/programs/*.S`) linked at address `0x0` by `cpu/programs/link.ld`, converted to one 32-bit word per line by `cpu/programs/bin2hex.py`. Instruction and data memory are separate 4 KB word arrays, both indexed by `addr[11:2]`.

| Program | Covers |
|---------|--------|
| `alu_r.S` | add, sub, sll, slt, sltu, xor, srl, sra, or, and |
| `alu_i.S` | addi, slti, sltiu, xori, ori, andi, slli, srli, srai, 12-bit imm limits |
| `upper.S` | lui, auipc |
| `mem.S` | lw/lh/lhu/lb/lbu and sw/sh/sb across all byte lanes, negative offsets |
| `branch.S` | beq, bne, blt, bge, bltu, bgeu taken and not-taken, backward loop, signed overflow compare |
| `jump.S` | jal link value, jalr with odd target (bit 0 cleared), call/return |
| `x0.S` | writes to x0 are dropped on every path, PC+4 write-back |

## Repository layout

```
.
├── cpu_sv_package.sv       shared enums
├── Makefile                test-all / clean-all
├── <block>/
│   ├── <block>.sv          RTL
│   ├── <block>_uarch.py    Python reference model
│   ├── python_stimulus_<block>.py   cocotb tests
│   ├── Makefile            compile + simulate with Icarus
│   ├── README.md           block description + tables
│   └── <block>_rtl.png     block diagram
└── cpu/
    ├── cpu.sv              top level
    ├── python_stimulus_cpu.py
    └── programs/           *.S sources, link.ld, bin2hex.py, generated *.hex
```

## Scope

RV32I base integer ISA, single cycle. No CSRs, `fence`, `ecall`/`ebreak`, M extension, or pipelining.

## Remote

The GitHub repository moved to `DawDa07/RISC-V-CPU`. If your clone still points at `risc-v-core`:

```sh
git remote set-url origin https://github.com/DawDa07/RISC-V-CPU.git
```
