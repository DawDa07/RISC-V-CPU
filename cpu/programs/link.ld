/* Minimal linker script for the single-cycle RV32I core.
 * IMEM and DMEM are separate 4 KB word arrays, both indexed by addr[11:2].
 * Code starts at 0x0 (PC reset value). Data addresses used by programs
 * are chosen manually and must stay inside 0x000..0xFFC.
 */
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS
{
  .text : {
    *(.text.init)
    *(.text*)
  } > IMEM

  .rodata : { *(.rodata*) } > IMEM

  /DISCARD/ : { *(.comment) *(.riscv.attributes) *(.note*) *(.eh_frame*) }
}
