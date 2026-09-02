# Python reference model for pc_reg.sv.

MASK32 = 0xFFFFFFFF
RESET_PC = 0x00000000


def module_pc_reg_reset():
    """Expected PC after active-low reset."""
    return RESET_PC


def module_pc_reg_capture(pc_d_i):
    """Expected PC on the cycle after a rising clock edge (not in reset)."""
    return pc_d_i & MASK32
