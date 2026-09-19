# JAL / JALR: link register = PC+4, JALR clears target LSB, call/return.
# Expected (layout below is fixed, all 4-byte instructions):
#   x1=0x04 x2=0x1D x3=0x1C x4=0x20 x5=0x34 x10=31 x11=0
#   final PC spins at 0x44
.section .text.init
.globl _start
_start:                                 # PC
    jal  x1, target1                    # 0x00: x1 = 0x04
    addi x11, x0, 1                     # 0x04: skipped
target1:
    addi x10, x0, 1                     # 0x08: x10 = 1

    # Odd JALR target: build &target2, set LSB with ori. Hardware clears it.
    auipc x2, 0                         # 0x0C: x2 = 0x0C
    addi  x2, x2, 16                    # 0x10: x2 = 0x1C = &target2
    ori   x2, x2, 1                     # 0x14: x2 = 0x1D (odd)
    jalr  x3, 0(x2)                     # 0x18: x3 = 0x1C, pc = 0x1C
target2:
    addi x10, x10, 2                    # 0x1C: x10 = 3

    # jalr with immediate offset and rd = x0
    auipc x4, 0                         # 0x20: x4 = 0x20
    jalr  x0, 12(x4)                    # 0x24: pc = 0x20 + 12 = 0x2C = target3
    addi  x11, x11, 2                   # 0x28: skipped
target3:
    addi x10, x10, 4                    # 0x2C: x10 = 7

    # call / return
    jal  x5, func                       # 0x30: x5 = 0x34
    addi x10, x10, 16                   # 0x34: x10 = 31 (after return)
    j    done                           # 0x38
func:
    addi x10, x10, 8                    # 0x3C: x10 = 15
    jalr x0, 0(x5)                      # 0x40: return to 0x34
done:
    j    done                           # 0x44
