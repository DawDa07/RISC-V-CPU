# Every conditional branch, taken and not-taken, forward and backward,
# plus a counted loop and a signed-overflow compare.
# x10 = number of checks that passed (expect 16)
# x11 = number of checks that failed (expect 0)
# x14 = id of the last failing check     (expect 0)
# x12 = 10+9+...+1 = 55, x13 = 0 (loop counter)
# x1=5 x2=0xFFFFFFFB x3=5 x4=0x80000000 x5=0x7FFFFFFF
.section .text.init
.globl _start
_start:
    addi x1,  x0, 5             # +5
    addi x2,  x0, -5            # -5 = 0xFFFFFFFB
    addi x3,  x0, 5             # +5 (equal to x1)
    addi x10, x0, 0
    addi x11, x0, 0
    addi x14, x0, 0

    # 1: beq taken (equal)
    beq  x1, x3, 1f
    addi x11, x11, 1
    addi x14, x0, 1
1:  addi x10, x10, 1

    # 2: beq not taken
    beq  x1, x2, 2f
    addi x10, x10, 1
    j    3f
2:  addi x11, x11, 1
    addi x14, x0, 2
3:
    # 3: bne taken
    bne  x1, x2, 4f
    addi x11, x11, 1
    addi x14, x0, 3
4:  addi x10, x10, 1

    # 4: bne not taken
    bne  x1, x3, 5f
    addi x10, x10, 1
    j    6f
5:  addi x11, x11, 1
    addi x14, x0, 4
6:
    # 5: blt taken (-5 < 5)
    blt  x2, x1, 7f
    addi x11, x11, 1
    addi x14, x0, 5
7:  addi x10, x10, 1

    # 6: blt not taken (5 < -5)
    blt  x1, x2, 8f
    addi x10, x10, 1
    j    9f
8:  addi x11, x11, 1
    addi x14, x0, 6
9:
    # 7: bge taken (5 >= -5)
    bge  x1, x2, 10f
    addi x11, x11, 1
    addi x14, x0, 7
10: addi x10, x10, 1

    # 8: bge not taken (-5 >= 5)
    bge  x2, x1, 11f
    addi x10, x10, 1
    j    12f
11: addi x11, x11, 1
    addi x14, x0, 8
12:
    # 9: bltu taken (5 <u 0xFFFFFFFB)
    bltu x1, x2, 13f
    addi x11, x11, 1
    addi x14, x0, 9
13: addi x10, x10, 1

    # 10: bltu not taken (0xFFFFFFFB <u 5)
    bltu x2, x1, 14f
    addi x10, x10, 1
    j    15f
14: addi x11, x11, 1
    addi x14, x0, 10
15:
    # 11: bgeu taken (0xFFFFFFFB >=u 5)
    bgeu x2, x1, 16f
    addi x11, x11, 1
    addi x14, x0, 11
16: addi x10, x10, 1

    # 12: bgeu not taken (5 >=u 0xFFFFFFFB)
    bgeu x1, x2, 17f
    addi x10, x10, 1
    j    18f
17: addi x11, x11, 1
    addi x14, x0, 12
18:
    # 13: bge equal (5 >= 5) taken
    bge  x1, x3, 19f
    addi x11, x11, 1
    addi x14, x0, 13
19: addi x10, x10, 1

    # 14: bgeu equal (5 >=u 5) taken
    bgeu x1, x3, 20f
    addi x11, x11, 1
    addi x14, x0, 14
20: addi x10, x10, 1

    # backward branch: x12 = 10 + 9 + ... + 1 = 55
    addi x12, x0, 0
    addi x13, x0, 10
loop:
    add  x12, x12, x13
    addi x13, x13, -1
    bne  x13, x0, loop

    # signed-overflow compare: INT_MIN vs INT_MAX (sub overflows, S != O)
    lui  x4, 0x80000            # INT_MIN
    lui  x5, 0x80000
    addi x5, x5, -1             # INT_MAX

    # 15: blt INT_MIN < INT_MAX taken
    blt  x4, x5, 21f
    addi x11, x11, 1
    addi x14, x0, 15
21: addi x10, x10, 1

    # 16: bltu INT_MIN <u INT_MAX not taken
    bltu x4, x5, 22f
    addi x10, x10, 1
    j    23f
22: addi x11, x11, 1
    addi x14, x0, 16
23:

end:
    j end
