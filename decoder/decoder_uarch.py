# Python reference model for decoder.sv (mirrors cpu_sv_package::opcode_e).

OPCODE_I_TYPE_LOAD = 0b0000011
OPCODE_I_TYPE_ALU = 0b0010011
OPCODE_U_TYPE_AUIPC = 0b0010111
OPCODE_S_TYPE = 0b0100011
OPCODE_R_TYPE = 0b0110011
OPCODE_U_TYPE_LUI = 0b0110111
OPCODE_B_TYPE = 0b1100011
OPCODE_I_TYPE_JALR = 0b1100111
OPCODE_J_TYPE = 0b1101111

MASK32 = 0xFFFFFFFF


def _sext(value, bits):
    """Sign-extend `bits`-wide value to 32 bits."""
    value &= (1 << bits) - 1
    sign = 1 << (bits - 1)
    if value & sign:
        value |= (~((1 << bits) - 1)) & MASK32
    return value & MASK32


def module_decoder(instr_i):
    """Python model matching decoder.sv.

    Returns (op, rd, rs1, rs2, f3, f7, imm).
    """
    instr = instr_i & MASK32

    op = instr & 0x7F
    rd = (instr >> 7) & 0x1F
    f3 = (instr >> 12) & 0x7
    rs1 = (instr >> 15) & 0x1F
    rs2 = (instr >> 20) & 0x1F
    f7 = (instr >> 25) & 0x7F

    i31 = (instr >> 31) & 0x1
    i31_20 = (instr >> 20) & 0xFFF
    i31_25 = (instr >> 25) & 0x7F
    i11_7 = (instr >> 7) & 0x1F
    i7 = (instr >> 7) & 0x1
    i30_25 = (instr >> 25) & 0x3F
    i11_8 = (instr >> 8) & 0xF
    i31_12 = (instr >> 12) & 0xFFFFF
    i19_12 = (instr >> 12) & 0xFF
    i20 = (instr >> 20) & 0x1
    i30_21 = (instr >> 21) & 0x3FF

    if op == OPCODE_R_TYPE:
        imm = 0
    elif op in (OPCODE_I_TYPE_ALU, OPCODE_I_TYPE_LOAD, OPCODE_I_TYPE_JALR):
        imm = _sext(i31_20, 12)
    elif op == OPCODE_S_TYPE:
        imm = _sext((i31_25 << 5) | i11_7, 12)
    elif op == OPCODE_B_TYPE:
        imm12 = (i31 << 12) | (i7 << 11) | (i30_25 << 5) | (i11_8 << 1)
        imm = _sext(imm12, 13)
    elif op in (OPCODE_U_TYPE_LUI, OPCODE_U_TYPE_AUIPC):
        imm = (i31_12 << 12) & MASK32
    elif op == OPCODE_J_TYPE:
        imm20 = (i31 << 20) | (i19_12 << 12) | (i20 << 11) | (i30_21 << 1)
        imm = _sext(imm20, 21)
    else:
        imm = 0

    return op, rd, rs1, rs2, f3, f7, imm
