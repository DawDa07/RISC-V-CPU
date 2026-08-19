# Python reference model for alu_in_muxes.sv (mirrors cpu_sv_package enums).

OP_A_PC = 0b00
OP_A_RS1 = 0b01
OP_A_ZERO = 0b10
OP_B_RS2 = 0b0
OP_B_IMM = 0b1


def get_max(width):
    """Largest unsigned value that fits in `width` bits."""
    return (1 << width) - 1


def module_alu_in_muxes(pc_curr_i, rs1_val_i, rs2_val_i, imm_i, s1_sel_i, s2_sel_i):
    """Python model matching alu_in_muxes.sv."""
    if s1_sel_i == OP_A_PC:
        alu_a = pc_curr_i
    elif s1_sel_i == OP_A_RS1:
        alu_a = rs1_val_i
    elif s1_sel_i == OP_A_ZERO:
        alu_a = 0
    else:
        alu_a = 0

    alu_b = imm_i if s2_sel_i == OP_B_IMM else rs2_val_i
    return alu_a, alu_b
