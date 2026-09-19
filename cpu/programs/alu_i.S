# I-type ALU ops incl. shift-immediates and 12-bit immediate limits.
# Expected:
#   x1=0xFFFFFF9C x10=50 x11=1 x12=0 x13=0 x14=1 x15=99 x16=0xFFFFFFFC x17=156
#   x5=0xFFFFF9C0 x6=15 x7=0xFFFFFFFF x8=2047 x9=0xFFFFF800
.section .text.init
.globl _start
_start:
    addi  x1,  x0, -100     # x1 = -100 = 0xFFFFFF9C
    addi  x10, x1, 150      # 50
    slti  x11, x1, -50      # -100 < -50   = 1
    slti  x12, x1, -200     # -100 < -200  = 0
    sltiu x13, x1, 5        # 0xFFFFFF9C <u 5 = 0
    sltiu x14, x0, 5        # 0 <u 5       = 1
    xori  x15, x1, -1       # ~(-100)      = 99
    ori   x16, x1, 0x0F0    # 0xFFFFFFFC
    andi  x17, x1, 0x0FF    # 0x9C = 156
    slli  x5,  x1, 4        # 0xFFFFF9C0
    srli  x6,  x1, 28       # 0xF = 15
    srai  x7,  x1, 28       # 0xFFFFFFFF
    addi  x8,  x0, 2047     # max positive imm
    addi  x9,  x0, -2048    # min negative imm = 0xFFFFF800

end:
    j end
