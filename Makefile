# Top-level helpers for the RISC-V CPU repo.
#
#   make test-all     run every block testbench (each <block>/Makefile), fail fast
#   make clean-all    remove sim_build/ and results.xml in every block
#   make programs     rebuild cpu/programs/*.hex (needs riscv64-elf-binutils)
#
# Block tests are cocotb + Icarus; see each block's Makefile.

# Every immediate subdirectory that has a Makefile and a cocotb MODULE.
BLOCKS := $(sort $(dir $(wildcard */Makefile)))
BLOCKS := $(filter-out cpu/programs/,$(BLOCKS))

.PHONY: test-all clean-all programs list $(BLOCKS)

test-all: $(BLOCKS)
	@echo ""
	@echo "All block testbenches passed: $(BLOCKS)"

$(BLOCKS):
	@echo ""
	@echo "=============================================================="
	@echo " $@"
	@echo "=============================================================="
	@$(MAKE) --no-print-directory -C $@

programs:
	@$(MAKE) --no-print-directory -C cpu/programs

clean-all:
	@for d in $(BLOCKS); do \
	    $(MAKE) --no-print-directory -C $$d clean >/dev/null 2>&1 || true; \
	    rm -rf $$d/sim_build $$d/results.xml $$d/__pycache__; \
	done
	@rm -rf sim_build results.xml __pycache__
	@echo "cleaned: $(BLOCKS)"

list:
	@printf '%s\n' $(BLOCKS)
