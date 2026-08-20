# Python reference model for alu.sv

ALU_ADD = 0
ALU_SUB = 1
ALU_SLT = 2
ALU_SLTU = 3
ALU_SLL = 4
ALU_XOR = 5
ALU_SRL = 6
ALU_SRA = 7
ALU_OR = 8
ALU_AND = 9

MASK32 = 0xFFFFFFFF
WIDTH = 32


def _to_signed(x):
    x &= MASK32
    if x >= (1 << (WIDTH - 1)):
        return x - (1 << WIDTH)
    return x


def module_alu(src1_i, src2_i, alu_op_i, width=WIDTH):
    """Python model matching alu.sv. Returns (res, z, s, ovfl, carry)."""
    mask = (1 << width) - 1
    src1 = src1_i & mask
    src2 = src2_i & mask
    shamt = src2 & 0x1F

    sign_src1 = (src1 >> (width - 1)) & 1
    sign_src2 = (src2 >> (width - 1)) & 1

    sum_full = (src1 + src2) & ((1 << (width + 1)) - 1)
    sum_trunc = sum_full & mask
    carry_add = (sum_full >> width) & 1
    sign_sum = (sum_trunc >> (width - 1)) & 1

    sub_full = (src1 - src2) & ((1 << (width + 1)) - 1)
    sub_trunc = sub_full & mask
    carry_sub = (sub_full >> width) & 1
    sign_sub = (sub_trunc >> (width - 1)) & 1

    slt_bit = sign_sub ^ ((sign_src1 != sign_src2) & (sign_sub != sign_src1))
    sltu_bit = carry_sub

    res = 0
    carry = 0
    ovfl = 0

    if alu_op_i == ALU_ADD:
        res = sum_trunc
        carry = carry_add
        ovfl = int((sign_src1 == sign_src2) and (sign_sum != sign_src1))
    elif alu_op_i == ALU_SUB:
        res = sub_trunc
        carry = 1 - carry_sub
        ovfl = int((sign_src1 != sign_src2) and (sign_sub != sign_src1))
    elif alu_op_i == ALU_SLT:
        res = slt_bit & 1
    elif alu_op_i == ALU_SLTU:
        res = sltu_bit & 1
    elif alu_op_i == ALU_SLL:
        res = (src1 << shamt) & mask
    elif alu_op_i == ALU_SRL:
        res = src1 >> shamt
    elif alu_op_i == ALU_SRA:
        res = (_to_signed(src1) >> shamt) & mask
    elif alu_op_i == ALU_XOR:
        res = src1 ^ src2
    elif alu_op_i == ALU_OR:
        res = src1 | src2
    elif alu_op_i == ALU_AND:
        res = src1 & src2
    else:
        res = src2

    res &= mask
    z = int(res == 0)
    s = (res >> (width - 1)) & 1
    return res, z, s, ovfl, carry
