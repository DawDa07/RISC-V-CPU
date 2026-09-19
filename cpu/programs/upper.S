# LUI / AUIPC. AUIPC results depend on this exact instruction layout.
# Expected:
#   x10=0x12345000 x11=0x4 x12=0x1008 x13=0xFFFFF000 x14=0xFFFFEFFF
#   x15=0x80000000 x16=0xFFFFF018
.section .text.init
.globl _start
_start:                         # PC
    lui   x10, 0x12345          # 0x00: 0x12345000
    auipc x11, 0                # 0x04: 0x4
    auipc x12, 0x1              # 0x08: 0x8 + 0x1000 = 0x1008
    lui   x13, 0xFFFFF          # 0x0C: 0xFFFFF000
    addi  x14, x13, -1          # 0x10: 0xFFFFEFFF
    lui   x15, 0x80000          # 0x14: 0x80000000
    auipc x16, 0xFFFFF          # 0x18: 0x18 + 0xFFFFF000 = 0xFFFFF018

end:
    j end
