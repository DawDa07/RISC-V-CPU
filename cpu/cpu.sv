import cpu_sv_package::*;

module cpu (
    input logic clk_i,
    input logic rst_ni  // Active-low reset (same polarity as pc_reg)
);

    // =========================================================================
    // Internal nets
    // =========================================================================

    // PC path
    logic [31:0] pc_q;
    logic [31:0] pc_plus_4;
    logic [31:0] pc_next;

    // Fetch / decode
    logic [31:0] instr;
    opcode_e     opcode;
    logic [4:0]  rd;
    logic [2:0]  funct3;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [6:0]  funct7;
    logic [31:0] imm;

    // Control
    logic       is_cond_branch;
    logic       is_jal;
    logic       is_jalr;
    logic [2:0] imm_src_unused;
    logic [1:0] alu_src1_ctrl;
    logic       alu_src2_ctrl;
    logic [3:0] alu_ctrl;
    logic       datamem_re_unused;
    logic       datamem_we;
    logic [1:0] data_mem2reg;
    logic       regfile_we;

    // Register file
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
    logic [31:0] rf_wd;

    // ALU
    logic [31:0] alu_a;
    logic [31:0] alu_b;
    logic [31:0] alu_res;
    logic        alu_z;
    logic        alu_s;
    logic        alu_ovfl;
    logic        alu_carry;

    // Branch / next PC
    logic [1:0] pc_src;
    logic [3:0] alu_flags;

    // Memory path
    logic [31:0] sau_wdata;
    logic [3:0]  sau_strobe;
    logic [31:0] dmem_rd;
    logic [31:0] lau_aligned;

    // Enum casts at control / mux boundaries
    sel_alu_a_e alu_a_sel;
    sel_alu_b_e alu_b_sel;
    alu_op_e    alu_op;
    wb_sel_e    wb_sel;

    assign alu_a_sel  = sel_alu_a_e'(alu_src1_ctrl);
    assign alu_b_sel  = sel_alu_b_e'(alu_src2_ctrl);
    assign alu_op     = alu_op_e'(alu_ctrl);
    assign wb_sel     = wb_sel_e'(data_mem2reg);
    assign alu_flags  = {alu_z, alu_s, alu_ovfl, alu_carry};

    // =========================================================================
    // Fetch / PC
    // =========================================================================

    pc_reg u_pc_reg (
        .clk_i   (clk_i),
        .rst_ni  (rst_ni),
        .pc_d_i  (pc_next),
        .pc_q_o  (pc_q)
    );

    pc_plus_4 u_pc_plus_4 (
        .pc_curr_i  (pc_q),
        .pc_plus_4_o(pc_plus_4)
    );

    instr_mem_wrapper u_imem (
        .pc_i    (pc_q),
        .instr_o (instr)
    );

    // =========================================================================
    // Decode / control
    // =========================================================================

    decoder u_decoder (
        .instr_i (instr),
        .op_o    (opcode),
        .rd_o    (rd),
        .f3_o    (funct3),
        .rs1_o   (rs1),
        .rs2_o   (rs2),
        .f7_o    (funct7),
        .imm_o   (imm)
    );

    ctrl u_ctrl (
        .opcode_i         (7'(opcode)),
        .funct3_i         (funct3),
        .funct7_i         (funct7),
        .is_cond_branch_o (is_cond_branch),
        .is_jal_o         (is_jal),
        .is_jalr_o        (is_jalr),
        .imm_src_o        (imm_src_unused),
        .alu_src1_ctrl_o  (alu_src1_ctrl),
        .alu_src2_ctrl_o  (alu_src2_ctrl),
        .alu_ctrl_o       (alu_ctrl),
        .datamem_re_o     (datamem_re_unused),
        .datamem_we_o     (datamem_we),
        .dataMem2Reg_o    (data_mem2reg),
        .regfile_we_o     (regfile_we)
    );

    // =========================================================================
    // Register file
    // =========================================================================

    reg_file u_reg_file (
        .clk_i (clk_i),
        .we_i  (regfile_we),
        .rs1_i (rs1),
        .rs2_i (rs2),
        .rd_i  (rd),
        .wd_i  (rf_wd),
        .rd1_o (rs1_val),
        .rd2_o (rs2_val)
    );

    // =========================================================================
    // Execute
    // =========================================================================

    alu_in_muxes u_alu_in_muxes (
        .pc_curr_i (pc_q),
        .rs1_val_i (rs1_val),
        .rs2_val_i (rs2_val),
        .imm_i     (imm),
        .s1_sel_i  (alu_a_sel),
        .s2_sel_i  (alu_b_sel),
        .alu_a_o   (alu_a),
        .alu_b_o   (alu_b)
    );

    alu u_alu (
        .src1_i   (alu_a),
        .src2_i   (alu_b),
        .alu_op_i (alu_op),
        .res_o    (alu_res),
        .z_o      (alu_z),
        .s_o      (alu_s),
        .ovfl_o   (alu_ovfl),
        .carry_o  (alu_carry)
    );

    bcu u_bcu (
        .f3_i             (funct3),
        .flags_i          (alu_flags),
        .is_cond_branch_i (is_cond_branch),
        .is_jal_i         (is_jal),
        .is_jalr_i        (is_jalr),
        .pc_src_o         (pc_src)
    );

    next_pc_logic u_next_pc_logic (
        .pc_curr_i   (pc_q),
        .pc_plus_4_i (pc_plus_4),
        .imm_i       (imm),
        .alu_res_i   (alu_res),
        .pc_src_i    (pc_src),
        .pc_next_o   (pc_next)
    );

    // =========================================================================
    // Memory + writeback
    // =========================================================================

    sau u_sau (
        .mem_we_i  (datamem_we),
        .rs2_val_i (rs2_val),
        .adrs_1_i  (alu_res[1]),
        .adrs_0_i  (alu_res[0]),
        .f3_i      (funct3),
        .wdata_o   (sau_wdata),
        .strobe_o  (sau_strobe)
    );

    data_mem_wrapper u_dmem (
        .clk_i  (clk_i),
        .we_i   (sau_strobe),
        .addr_i (alu_res),
        .wd_i   (sau_wdata),
        .rd_o   (dmem_rd)
    );

    lau u_lau (
        .mem_data_i     (dmem_rd),
        .adrs_1_i       (alu_res[1]),
        .adrs_0_i       (alu_res[0]),
        .funct3_i       (funct3),
        .aligned_data_o (lau_aligned)
    );

    rf_wb_mux u_rf_wb_mux (
        .alu_res_i   (alu_res),
        .lau_res_i   (lau_aligned),
        .pc_plus_4_i (pc_plus_4),
        .d2r_sel_i   (wb_sel),
        .rf_wd_o     (rf_wd)
    );

endmodule
