# Python reference model for ctrl.sv (main control decoder).

# Opcodes
OP_R_TYPE = 51    # 0x33
OP_I_TYPE_ALU = 19  # 0x13
OP_LOAD = 3       # 0x03
OP_STORE = 35     # 0x23
OP_BRANCH = 99    # 0x63
OP_LUI = 55       # 0x37
OP_AUIPC = 23     # 0x17
OP_JALR = 103     # 0x67
OP_JAL = 111      # 0x6F


def module_ctrl(opcode_i, funct3_i, funct7_i, DEBUG_MODE=False):
    """Python model matching ctrl.sv.

    Returns (is_cond_branch_o, is_jal_o, is_jalr_o, imm_src_o,
             alu_src1_ctrl_o, alu_src2_ctrl_o, alu_ctrl_o,
             datamem_re_o, datamem_we_o, dataMem2Reg_o, regfile_we_o).
    """
    op = opcode_i & 0x7F

    # Hardware defaults (reset state)
    is_cond_branch = 0
    is_jal = 0
    is_jalr = 0
    imm_src = 0
    alu_src1_ctrl = 1   # RS1
    alu_src2_ctrl = 0   # RS2
    alu_ctrl = 0        # ADD
    datamem_re = 0
    datamem_we = 0
    data_mem2reg = 0    # ALU out
    regfile_we = 0

    if op == OP_R_TYPE:
        regfile_we = 1
        if funct3_i == 0:
            alu_ctrl = 1 if funct7_i == 32 else 0   # SUB : ADD
        elif funct3_i == 1:
            alu_ctrl = 2   # SLL
        elif funct3_i == 2:
            alu_ctrl = 3   # SLT
        elif funct3_i == 3:
            alu_ctrl = 4   # SLTU
        elif funct3_i == 4:
            alu_ctrl = 5   # XOR
        elif funct3_i == 5:
            alu_ctrl = 7 if funct7_i == 32 else 6   # SRA : SRL
        elif funct3_i == 6:
            alu_ctrl = 8   # OR
        elif funct3_i == 7:
            alu_ctrl = 9   # AND

    elif op == OP_I_TYPE_ALU:
        regfile_we = 1
        alu_src2_ctrl = 1
        if funct3_i == 0:
            alu_ctrl = 0   # ADDI
        elif funct3_i == 1:
            alu_ctrl = 2   # SLLI
        elif funct3_i == 2:
            alu_ctrl = 3   # SLTI
        elif funct3_i == 3:
            alu_ctrl = 4   # SLTIU
        elif funct3_i == 4:
            alu_ctrl = 5   # XORI
        elif funct3_i == 5:
            alu_ctrl = 7 if funct7_i == 32 else 6   # SRAI : SRLI
        elif funct3_i == 6:
            alu_ctrl = 8   # ORI
        elif funct3_i == 7:
            alu_ctrl = 9   # ANDI

    elif op == OP_LOAD:
        regfile_we = 1
        alu_src2_ctrl = 1
        datamem_re = 1
        data_mem2reg = 1

    elif op == OP_STORE:
        imm_src = 1
        alu_src2_ctrl = 1
        datamem_we = 1

    elif op == OP_BRANCH:
        is_cond_branch = 1
        imm_src = 2
        alu_ctrl = 1   # SUB

    elif op == OP_LUI:
        regfile_we = 1
        imm_src = 3
        alu_src1_ctrl = 2   # Zero
        alu_src2_ctrl = 1

    elif op == OP_AUIPC:
        regfile_we = 1
        imm_src = 3
        alu_src1_ctrl = 0   # PC
        alu_src2_ctrl = 1

    elif op == OP_JALR:
        is_jalr = 1
        regfile_we = 1
        alu_src1_ctrl = 1
        alu_src2_ctrl = 1
        alu_ctrl = 0
        data_mem2reg = 2

    elif op == OP_JAL:
        is_jal = 1
        regfile_we = 1
        imm_src = 4
        data_mem2reg = 2

    result = (
        is_cond_branch, is_jal, is_jalr, imm_src,
        alu_src1_ctrl, alu_src2_ctrl, alu_ctrl,
        datamem_re, datamem_we, data_mem2reg, regfile_we,
    )

    if DEBUG_MODE:
        print(f"ctrl(op={op}, f3={funct3_i}, f7={funct7_i}) -> {result}")

    return result
