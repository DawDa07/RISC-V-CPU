SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../cpu_sv_package.sv
VERILOG_SOURCES += $(PWD)/alu_in_muxes.sv
TOPLEVEL = alu_in_muxes
MODULE = python_stimulus_alu_in_muxes

COMPILE_ARGS += -g2012
#export COCOTB_LOG_LEVEL = WARNING
export COCOTB_HDL_TIMEUNIT = 1ns
export COCOTB_HDL_TIMEPRECISION = 1ps

include $(shell cocotb-config --makefiles)/Makefile.sim
