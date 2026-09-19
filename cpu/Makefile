SIM ?= icarus
TOPLEVEL_LANG ?= verilog

PWD := $(shell pwd)

VERILOG_SOURCES += $(PWD)/../cpu_sv_package.sv
VERILOG_SOURCES += $(PWD)/cpu.sv
VERILOG_SOURCES += $(PWD)/../pc_reg/pc_reg.sv
VERILOG_SOURCES += $(PWD)/../pc_plus_4/pc_plus_4.sv
VERILOG_SOURCES += $(PWD)/../instr_mem_wrapper/instr_mem_behavioral.sv
VERILOG_SOURCES += $(PWD)/../instr_mem_wrapper/instr_mem_wrapper.sv
VERILOG_SOURCES += $(PWD)/../decoder/decoder.sv
VERILOG_SOURCES += $(PWD)/../ctrl/ctrl.sv
VERILOG_SOURCES += $(PWD)/../reg_file/reg_file.sv
VERILOG_SOURCES += $(PWD)/../alu_in_muxes/alu_in_muxes.sv
VERILOG_SOURCES += $(PWD)/../alu/alu.sv
VERILOG_SOURCES += $(PWD)/../bcu/bcu.sv
VERILOG_SOURCES += $(PWD)/../next_pc_logic/next_pc_logic.sv
VERILOG_SOURCES += $(PWD)/../sau/sau.sv
VERILOG_SOURCES += $(PWD)/../data_mem_wrapper/data_mem_behavioral.sv
VERILOG_SOURCES += $(PWD)/../data_mem_wrapper/data_mem_wrapper.sv
VERILOG_SOURCES += $(PWD)/../lau/lau.sv
VERILOG_SOURCES += $(PWD)/../rf_wb_mux/rf_wb_mux.sv

TOPLEVEL = cpu
MODULE = python_stimulus_cpu

COMPILE_ARGS += -g2012
#export COCOTB_LOG_LEVEL = WARNING
export COCOTB_HDL_TIMEUNIT = 1ns
export COCOTB_HDL_TIMEPRECISION = 1ps

include $(shell cocotb-config --makefiles)/Makefile.sim

# -----------------------------------------------------------------------------
# Test programs: rebuild programs/*.hex from programs/*.S when the RISC-V
# binutils are available; otherwise fall back to the committed .hex files.
# -----------------------------------------------------------------------------
RISCV_AS := $(shell command -v riscv64-elf-as 2>/dev/null)

.PHONY: programs
programs:
ifneq ($(RISCV_AS),)
	@$(MAKE) --no-print-directory -C programs
else
	@if ls programs/*.hex >/dev/null 2>&1; then \
	    echo "riscv64-elf-binutils not found; using committed programs/*.hex"; \
	else \
	    echo "ERROR: no RISC-V toolchain and no prebuilt programs/*.hex"; exit 1; \
	fi
endif

sim: programs
