SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/pc_reg.sv
TOPLEVEL = pc_reg
MODULE = python_stimulus_pc_reg

COMPILE_ARGS += -g2012
#export COCOTB_LOG_LEVEL = WARNING
export COCOTB_HDL_TIMEUNIT = 1ns
export COCOTB_HDL_TIMEPRECISION = 1ps

include $(shell cocotb-config --makefiles)/Makefile.sim
