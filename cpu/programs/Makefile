# Assemble test programs for the single-cycle RV32I core.
#
#   make            build every *.S into *.hex
#   make clean      remove intermediates and hex files
#
# Requires riscv64-elf-binutils (brew install riscv64-elf-binutils).

PREFIX  ?= riscv64-elf-
AS      := $(PREFIX)as
LD      := $(PREFIX)ld
OBJCOPY := $(PREFIX)objcopy
PYTHON  ?= python3

ASFLAGS := -march=rv32i -mabi=ilp32
LDFLAGS := -m elf32lriscv -T link.ld --no-warn-rwx-segments

SRCS := $(wildcard *.S)
HEXS := $(SRCS:.S=.hex)

.PHONY: all clean clean-hex
all: $(HEXS)

%.o: %.S
	$(AS) $(ASFLAGS) -o $@ $<

%.elf: %.o link.ld
	$(LD) $(LDFLAGS) -o $@ $<

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.hex: %.bin bin2hex.py
	$(PYTHON) bin2hex.py $< $@

# Keep committed *.hex; only wipe assemble/link intermediates.
clean:
	rm -f *.o *.elf *.bin

# Explicit wipe of generated images (re-run `make` to rebuild).
clean-hex: clean
	rm -f $(HEXS)
