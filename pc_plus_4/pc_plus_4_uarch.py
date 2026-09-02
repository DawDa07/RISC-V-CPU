# Python reference model for pc_plus_4.sv.

MASK32 = 0xFFFFFFFF


def module_pc_plus_4(pc_curr_i):
    """Python model matching pc_plus_4.sv. Returns pc_plus_4_o."""
    return (pc_curr_i + 4) & MASK32
