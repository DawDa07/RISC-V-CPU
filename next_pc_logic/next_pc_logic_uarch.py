# Python reference model for next_pc_logic.sv.

MASK32 = 0xFFFFFFFF

PC_SRC_PC4 = 0b00
PC_SRC_BRANCH = 0b01
PC_SRC_JALR = 0b10


def module_pc_plus_4(pc_curr_i):
    """PC + 4 with 32-bit wraparound."""
    return (pc_curr_i + 4) & MASK32


def module_next_pc_logic(pc_curr_i, pc_plus_4_i, imm_i, alu_res_i, pc_src_i):
    """Python model matching next_pc_logic.sv. Returns pc_next_o."""
    branch_target = (pc_curr_i + imm_i) & MASK32
    jalr_target = alu_res_i & 0xFFFFFFFE

    if pc_src_i == PC_SRC_JALR:
        return jalr_target & MASK32
    if pc_src_i == PC_SRC_BRANCH:
        return branch_target
    return pc_plus_4_i & MASK32
