# Python reference model for lau.sv (Load Alignment Unit).

MASK32 = 0xFFFFFFFF


def module_lau(mem_data_i, adrs_1_i, adrs_0_i, funct3_i):
    """Python model matching lau.sv.

    Returns aligned_data_o.
    """
    mem = mem_data_i & MASK32
    stage1 = (mem >> 16) & MASK32 if adrs_1_i else mem
    stage2 = (stage1 >> 8) & MASK32 if adrs_0_i else stage1

    s2_byte = stage2 & 0xFF
    s2_hw = stage2 & 0xFFFF
    s2_byte_sign = (stage2 >> 7) & 1
    s2_hw_sign = (stage2 >> 15) & 1

    if funct3_i == 0b000:  # lb
        aligned = (s2_byte | 0xFFFFFF00) & MASK32 if s2_byte_sign else s2_byte
    elif funct3_i == 0b001:  # lh
        aligned = (s2_hw | 0xFFFF0000) & MASK32 if s2_hw_sign else s2_hw
    elif funct3_i == 0b010:  # lw
        aligned = stage2
    elif funct3_i == 0b100:  # lbu
        aligned = s2_byte
    elif funct3_i == 0b101:  # lhu
        aligned = s2_hw
    else:
        aligned = 0

    return aligned & MASK32
