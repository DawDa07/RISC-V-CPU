# Loads/stores across all byte lanes with sign/zero extension.
# Data lives in DMEM at 0x100..0x10C.
# Expected regs:
#   x1=0x100 x2=0xDEADBEEF
#   x10=0xDEADBEEF x11=0xFFFFFFEF x12=0xEF x13=0xFFFFFFBE x14=0xAD x15=0xFFFFFFDE
#   x16=0xFFFFBEEF x17=0xDEAD
#   x3=0x11 x4=0x22 x5=0x44332211 x6=0xABCD1234 x7=0xFFFFABCD x8=0x1234 x9=0xDEADBEEF
# Expected DMEM:
#   [0x100]=0xDEADBEEF [0x104]=0x44332211 [0x108]=0xDEADBEEF
.section .text.init
.globl _start
_start:
    addi x1, x0, 0x100          # data base
    lui  x2, 0xDEADC
    addi x2, x2, -0x111         # x2 = 0xDEADBEEF

    # word store, then every load flavour from it
    sw   x2,  0(x1)             # [0x100] = 0xDEADBEEF
    lw   x10, 0(x1)             # 0xDEADBEEF
    lb   x11, 0(x1)             # 0xEF -> 0xFFFFFFEF
    lbu  x12, 0(x1)             # 0xEF
    lb   x13, 1(x1)             # 0xBE -> 0xFFFFFFBE
    lbu  x14, 2(x1)             # 0xAD
    lb   x15, 3(x1)             # 0xDE -> 0xFFFFFFDE
    lh   x16, 0(x1)             # 0xBEEF -> 0xFFFFBEEF
    lhu  x17, 2(x1)             # 0xDEAD

    # byte stores into all four lanes of [0x104]
    addi x3, x0, 0x11
    addi x4, x0, 0x22
    addi x5, x0, 0x33
    addi x6, x0, 0x44
    sb   x3, 4(x1)              # lane 0
    sb   x4, 5(x1)              # lane 1
    sb   x5, 6(x1)              # lane 2
    sb   x6, 7(x1)              # lane 3
    lw   x5, 4(x1)              # 0x44332211

    # halfword stores into both halves of [0x108]
    lui  x7, 0x1
    addi x7, x7, 0x234          # 0x1234
    lui  x8, 0xB
    addi x8, x8, -0x433         # 0xABCD
    sh   x7, 8(x1)              # low half
    sh   x8, 10(x1)             # high half
    lw   x6, 8(x1)              # 0xABCD1234
    lh   x7, 10(x1)             # 0xABCD -> 0xFFFFABCD
    lhu  x8, 8(x1)              # 0x1234

    # negative offset addressing, overwrite [0x108]
    addi x9, x1, 16             # 0x110
    sw   x10, -8(x9)            # [0x108] = 0xDEADBEEF
    lw   x9, -8(x9)             # 0xDEADBEEF

end:
    j end
