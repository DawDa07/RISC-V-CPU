# R-type ALU ops with signed/unsigned edge values.
# Expected (see python_stimulus_cpu.py):
#   x1=7 x2=0xFFFFFFFD x3=0x80000000 x4=1
#   x10=4 x11=10 x12=128 x13=1 x14=0 x15=0xFFFFFFFA x16=0x01000000 x17=0xFF000000
#   x5=0xFFFFFFFF x6=5 x7=0 x8=1 x9=0x7FFFFFFF
.section .text.init
.globl _start
_start:
    addi x1, x0, 7          # x1 = 7
    addi x2, x0, -3         # x2 = -3
    lui  x3, 0x80000        # x3 = INT_MIN
    addi x4, x0, 1          # x4 = 1

    add  x10, x1, x2        # 7 + (-3)      = 4
    sub  x11, x1, x2        # 7 - (-3)      = 10
    sll  x12, x4, x1        # 1 << 7        = 128
    slt  x13, x2, x1        # -3 < 7        = 1
    sltu x14, x2, x1        # 0xFFFFFFFD <u 7 = 0
    xor  x15, x1, x2        # 7 ^ -3        = 0xFFFFFFFA
    srl  x16, x3, x1        # INT_MIN >> 7  = 0x01000000
    sra  x17, x3, x1        # INT_MIN >>> 7 = 0xFF000000
    or   x5,  x1, x2        # 7 | -3        = 0xFFFFFFFF
    and  x6,  x1, x2        # 7 & -3        = 5
    slt  x7,  x1, x3        # 7 < INT_MIN   = 0
    sltu x8,  x1, x3        # 7 <u INT_MIN  = 1
    sub  x9,  x3, x4        # INT_MIN - 1   = 0x7FFFFFFF (wraps)

end:
    j end
