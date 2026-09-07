SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/instr_mem_behavioral.sv
VERILOG_SOURCES += $(PWD)/instr_mem_wrapper.sv
TOPLEVEL = instr_mem_wrapper
MODULE = python_stimulus_instr_mem_wrapper

COMPILE_ARGS += -g2012
#export COCOTB_LOG_LEVEL = WARNING
export COCOTB_HDL_TIMEUNIT = 1ns
export COCOTB_HDL_TIMEPRECISION = 1ps

include $(shell cocotb-config --makefiles)/Makefile.sim
