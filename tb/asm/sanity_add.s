#==============================================================================
# sanity_add.s — Minimal handwritten RV32I assembly smoke test
#
# Computes: x3 = x1 + x2  where x1=5, x2=3  =>  x3=8
# Then writes the result to a known DMEM address and hits ebreak.
#
# Build (via Makefile):
#   make asm/sanity_add.hex
#==============================================================================

    .section .text.init, "ax"
    .global _start
    .align 2

_start:
    # Set up a trivial stack pointer (top of 64 KiB RAM)
    lui     sp, 0x10            # sp = 0x00010000
    addi    sp, sp, -16

    # x1 = 5
    addi    x1, x0, 5

    # x2 = 3
    addi    x2, x0, 3

    # x3 = x1 + x2  (= 8)
    add     x3, x1, x2

    # Store result to DMEM[0x100] for testbench inspection
    lui     x4, 0x0
    addi    x4, x4, 0x100       # x4 = 0x00000100
    sw      x3, 0(x4)

    # Optional: poke UART TX data register @ 0x10000000 with ASCII 'O' 'K'
    lui     x5, 0x10000         # x5 = 0x10000000
    addi    x6, x0, 'O'
    sw      x6, 0(x5)
    addi    x6, x0, 'K'
    sw      x6, 0(x5)

    # Halt: ebreak — cpu_core should raise debug_halted when implemented
    ebreak

hang:
    jal     x0, hang
