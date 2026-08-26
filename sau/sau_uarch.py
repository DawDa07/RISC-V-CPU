# Python reference model for sau.sv (Store Alignment Unit).

MASK32 = 0xFFFFFFFF


def module_sau(mem_we_i, rs2_val_i, adrs_1_i, adrs_0_i, f3_i):
    """Python model matching sau.sv.

    Returns (wdata_o, strobe_o).
    """
    rs2 = rs2_val_i & MASK32
    rs2_byte = rs2 & 0xFF
    rs2_hw = rs2 & 0xFFFF

    wdata = rs2
    raw_strobe = 0

    if f3_i == 0b000:  # sb
        wdata = (rs2_byte << 24) | (rs2_byte << 16) | (rs2_byte << 8) | rs2_byte
        shift = ((adrs_1_i & 1) << 1) | (adrs_0_i & 1)
        raw_strobe = (0b0001 << shift) & 0xF
    elif f3_i == 0b001:  # sh
        wdata = ((rs2_hw << 16) | rs2_hw) & MASK32
        raw_strobe = 0b1100 if (adrs_1_i & 1) else 0b0011
    elif f3_i == 0b010:  # sw
        wdata = rs2
        raw_strobe = 0b1111
    else:
        wdata = rs2
        raw_strobe = 0

    strobe = raw_strobe if mem_we_i else 0
    return wdata & MASK32, strobe & 0xF
