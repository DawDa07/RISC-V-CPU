# x0 is hardwired to zero, and the PC+4 write-back path via JAL.
# Expected regs:
#   x10=0 x11=0 x12=77 x13=0 x14=1 x15=0x38 x16=0x38 x1=0x10 x2=77
# Expected DMEM: [0x10]=0 [0x14]=77
.section .text.init
.globl _start
_start:                         # PC
    addi x0,  x0, 5             # 0x00: write to x0 must be dropped
    addi x10, x0, 0             # 0x04: x10 = 0
    lui  x0,  0xFFFFF           # 0x08: dropped
    add  x11, x0, x0            # 0x0C: 0
    addi x1,  x0, 0x10          # 0x10: DMEM address
    sw   x0,  0(x1)             # 0x14: [0x10] = 0
    addi x2,  x0, 77            # 0x18
    sw   x2,  4(x1)             # 0x1C: [0x14] = 77
    lw   x0,  4(x1)             # 0x20: load into x0 dropped
    add  x12, x0, x2            # 0x24: 77
    jal  x0,  1f                # 0x28: plain jump, no link
    addi x13, x0, 99            # 0x2C: skipped
1:  addi x14, x0, 1             # 0x30: 1
    jal  x15, 2f                # 0x34: x15 = 0x38
2:  addi x16, x15, 0            # 0x38: 0x38

end:
    j end                       # 0x3C
