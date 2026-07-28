#==============================================================================
# Makefile — RV32I Pipelined Core build, simulation, and synthesis
#==============================================================================

#------------------------------------------------------------------------------
# Toolchain
#------------------------------------------------------------------------------
VERILATOR  ?= verilator
RISCV_PREFIX ?= riscv64-unknown-elf-
AS         := $(RISCV_PREFIX)as
LD         := $(RISCV_PREFIX)ld
OBJCOPY    := $(RISCV_PREFIX)objcopy
OBJDUMP    := $(RISCV_PREFIX)objdump
YOSYS      ?= yosys

# Prefer 32-bit multilib flags for RV32I
ASFLAGS    := -march=rv32i -mabi=ilp32
LDFLAGS    := -m elf32lriscv -T tb/asm/link.ld

#------------------------------------------------------------------------------
# Directories / sources
#------------------------------------------------------------------------------
RTL_CORE   := $(wildcard rtl/core/*.sv)
RTL_MEM    := $(wildcard rtl/memory/*.sv)
RTL_TOP    := rtl/soc_top.sv
RTL_SRCS   := $(RTL_CORE) $(RTL_MEM) $(RTL_TOP)

TB_CPP     := tb/cpp/testbench.cpp
BUILD_DIR  := build
SIM_DIR    := $(BUILD_DIR)/sim
ASM_DIR    := tb/asm
HEX_DIR    := $(BUILD_DIR)/hex

TOP_MODULE := soc_top
SIM_EXE    := $(SIM_DIR)/V$(TOP_MODULE)

# Verilator flags
VFLAGS := -Wall --cc --exe --build \
          -Mdir $(SIM_DIR) \
          --top-module $(TOP_MODULE) \
          -CFLAGS "-std=c++17 -I../../tb/cpp" \
          --trace

# Optional: silence undriven-output warnings while RTL stubs are empty
VFLAGS += -Wno-UNOPTFLAT -Wno-UNDRIVEN -Wno-UNUSED -Wno-UNUSEDPARAM -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME

#------------------------------------------------------------------------------
# Default target
#------------------------------------------------------------------------------
.PHONY: all
all: sim

#------------------------------------------------------------------------------
# Verilator simulation build
#------------------------------------------------------------------------------
.PHONY: sim
sim: $(SIM_EXE)

$(SIM_EXE): $(RTL_SRCS) $(TB_CPP) tb/cpp/scoreboard.hpp
	@mkdir -p $(SIM_DIR)
	$(VERILATOR) $(VFLAGS) $(RTL_SRCS) $(TB_CPP) -o V$(TOP_MODULE)

#------------------------------------------------------------------------------
# Run simulation with a given hex (default: sanity_add)
#------------------------------------------------------------------------------
TEST      ?= sanity_add
MAX_CYCLES ?= 10000

.PHONY: run
run: $(SIM_EXE) $(HEX_DIR)/$(TEST).hex
	$(SIM_EXE) $(HEX_DIR)/$(TEST).hex --cycles $(MAX_CYCLES) --verbose

.PHONY: run-trace
run-trace: $(SIM_EXE) $(HEX_DIR)/$(TEST).hex
	$(SIM_EXE) $(HEX_DIR)/$(TEST).hex --cycles $(MAX_CYCLES) --verbose --trace
	@echo "Waveform written to wave.vcd"

#------------------------------------------------------------------------------
# Assembly → ELF → flat hex
#------------------------------------------------------------------------------
.PHONY: asm
asm: $(HEX_DIR)/sanity_add.hex

$(HEX_DIR)/%.hex: $(ASM_DIR)/%.s $(ASM_DIR)/link.ld
	@mkdir -p $(HEX_DIR) $(BUILD_DIR)/obj
	$(AS) $(ASFLAGS) -o $(BUILD_DIR)/obj/$*.o $<
	$(LD) $(LDFLAGS) -o $(BUILD_DIR)/obj/$*.elf $(BUILD_DIR)/obj/$*.o
	$(OBJCOPY) -O verilog --verilog-data-width 4 $(BUILD_DIR)/obj/$*.elf $@
	$(OBJDUMP) -d $(BUILD_DIR)/obj/$*.elf > $(BUILD_DIR)/obj/$*.dis
	@echo "Built $@"

# Fallback: if no RISC-V toolchain, emit a hand-encoded hex for sanity_add
.PHONY: asm-fallback
asm-fallback:
	@mkdir -p $(HEX_DIR)
	@printf '%s\n' \
		'01000137' \
		'ff010113' \
		'00500093' \
		'00300113' \
		'002081b3' \
		'00000237' \
		'10020213' \
		'00322023' \
		'100002b7' \
		'04f00313' \
		'0062a023' \
		'04b00313' \
		'0062a023' \
		'00100073' \
		'0000006f' \
		> $(HEX_DIR)/sanity_add.hex
	@echo "Wrote fallback $(HEX_DIR)/sanity_add.hex (hand-encoded sanity_add)"

#------------------------------------------------------------------------------
# Yosys synthesis
#------------------------------------------------------------------------------
.PHONY: synth
synth:
	$(YOSYS) -s syn/yosys_synth.ys

#------------------------------------------------------------------------------
# Lint (Verilator --lint-only)
#------------------------------------------------------------------------------
.PHONY: lint
lint:
	$(VERILATOR) --lint-only -Wall -Wno-DECLFILENAME \
		-Wno-UNDRIVEN -Wno-UNUSED -Wno-UNUSEDPARAM -Wno-UNUSEDSIGNAL \
		--top-module $(TOP_MODULE) $(RTL_SRCS)

#------------------------------------------------------------------------------
# Clean
#------------------------------------------------------------------------------
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) wave.vcd

.PHONY: help
help:
	@echo "Targets:"
	@echo "  make sim            Build Verilator simulation executable"
	@echo "  make run            Build + run TEST=$(TEST) for MAX_CYCLES=$(MAX_CYCLES)"
	@echo "  make run-trace      Same as run, with VCD dump"
	@echo "  make asm            Assemble tb/asm/*.s → build/hex/*.hex"
	@echo "  make asm-fallback   Emit hand-encoded sanity_add.hex (no toolchain)"
	@echo "  make lint           Verilator lint-only pass"
	@echo "  make synth          Yosys synthesis (syn/yosys_synth.ys)"
	@echo "  make clean          Remove build artifacts"
