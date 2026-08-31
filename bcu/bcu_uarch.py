# Python reference model for bcu.sv (Branch Control Unit).

PC_SRC_PC4 = 0b00
PC_SRC_TARGET_IMM = 0b01
PC_SRC_ALU_RES = 0b10


def module_bcu(f3_i, flags_i, is_cond_branch_i, is_jal_i, is_jalr_i):
    """Python model matching bcu.sv.

    flags_i is the (Z, S, O, C) tuple. Returns pc_src_o.
    """
    z_i, s_i, o_i, c_i = flags_i

    take_branch = False
    if is_cond_branch_i:
        if f3_i == 0b000:    # BEQ
            take_branch = z_i == 1
        elif f3_i == 0b001:  # BNE
            take_branch = z_i == 0
        elif f3_i == 0b100:  # BLT
            take_branch = s_i != o_i
        elif f3_i == 0b101:  # BGE
            take_branch = s_i == o_i
        elif f3_i == 0b110:  # BLTU
            take_branch = c_i == 0
        elif f3_i == 0b111:  # BGEU
            take_branch = c_i == 1

    if is_jalr_i:
        return PC_SRC_ALU_RES
    if is_jal_i or take_branch:
        return PC_SRC_TARGET_IMM
    return PC_SRC_PC4
