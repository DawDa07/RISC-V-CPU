/*==============================================================================
 * link.ld — Bare-metal linker script for the RV32I simulation SoC
 *
 * Memory layout:
 *   RAM @ 0x00000000  (64 KiB unified instruction / data)
 *
 * Sections:
 *   .text.init  — reset / entry stub (must be first)
 *   .text       — code
 *   .rodata     — read-only data
 *   .data       — initialized data
 *   .bss        — zero-initialized data
 *   stack grows down from the top of RAM
 *============================================================================*/

OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

SECTIONS
{
    .text.init : {
        *(.text.init)
    } > RAM

    .text : {
        *(.text .text.*)
    } > RAM

    .rodata : {
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
    } > RAM

    .data : {
        *(.data .data.*)
        *(.sdata .sdata.*)
    } > RAM

    .bss : {
        __bss_start = .;
        *(.bss .bss.*)
        *(.sbss .sbss.*)
        *(COMMON)
        __bss_end = .;
    } > RAM

    /* Stack: 4 KiB reserved at top of RAM */
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
    _stack_bottom = _stack_top - 4K;

    /* Heap starts after BSS, grows toward stack */
    _end = .;
    PROVIDE(_heap_start = .);
}
