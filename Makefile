# Simulator settings
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Paths to your files
VERILOG_SOURCES += $(PWD)/nand_gate.sv
TOPLEVEL = nand_gate        # The name of the module in SV
COCOTB_TEST_MODULES = test_nand     # The name of the Python file

# Enable Waveform Dumping (for GTKWave)
COMPILE_ARGS += -g2012
export COCOTB_HDL_TIMEUNIT = 1ns
export COCOTB_HDL_TIMEPRECISION = 1ps

include $(shell cocotb-config --makefiles)/Makefile.sim
