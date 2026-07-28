//==============================================================================
// Module: id_ex_reg
// Description: ID/EX pipeline register.
//              Latches decoded control signals, register data, and immediates
//              from Decode into Execute.
//==============================================================================

module id_ex_reg (
    input  logic        clk,                // System clock
    input  logic        rst_n,              // Active-low asynchronous reset
    input  logic        stall,              // Stall: hold register contents
    input  logic        flush,              // Flush: insert bubble (NOP)

    // ---- ID stage data inputs ----
    input  logic [31:0] id_pc,              // PC from Decode
    input  logic [31:0] id_rs1_data,        // Register file rs1 read data
    input  logic [31:0] id_rs2_data,        // Register file rs2 read data
    input  logic [31:0] id_imm,             // Sign-extended immediate
    input  logic [4:0]  id_rs1_addr,        // rs1 address (for forwarding)
    input  logic [4:0]  id_rs2_addr,        // rs2 address (for forwarding)
    input  logic [4:0]  id_rd_addr,         // Destination register address

    // ---- ID stage control inputs ----
    input  logic        id_reg_write,       // Write-back enable
    input  logic        id_mem_read,        // Data memory read enable
    input  logic        id_mem_write,       // Data memory write enable
    input  logic        id_alu_src,         // ALU operand B select (0=rs2, 1=imm)
    input  logic [1:0]  id_wb_sel,          // Write-back mux select
    input  logic [3:0]  id_alu_op,          // ALU operation code
    input  logic        id_branch,          // Branch instruction flag
    input  logic        id_jump,            // Jump instruction flag
    input  logic [2:0]  id_funct3,          // funct3 field (branch/load/store type)

    // ---- EX stage data outputs ----
    output logic [31:0] ex_pc,
    output logic [31:0] ex_rs1_data,
    output logic [31:0] ex_rs2_data,
    output logic [31:0] ex_imm,
    output logic [4:0]  ex_rs1_addr,
    output logic [4:0]  ex_rs2_addr,
    output logic [4:0]  ex_rd_addr,

    // ---- EX stage control outputs ----
    output logic        ex_reg_write,
    output logic        ex_mem_read,
    output logic        ex_mem_write,
    output logic        ex_alu_src,
    output logic [1:0]  ex_wb_sel,
    output logic [3:0]  ex_alu_op,
    output logic        ex_branch,
    output logic        ex_jump,
    output logic [2:0]  ex_funct3
);

    // TODO: Hand-code implementation here

endmodule
