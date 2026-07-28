//==============================================================================
// Module: ex_mem_reg
// Description: EX/MEM pipeline register.
//              Latches ALU results and memory control from Execute into Memory.
//==============================================================================

module ex_mem_reg (
    input  logic        clk,                // System clock
    input  logic        rst_n,              // Active-low asynchronous reset
    input  logic        stall,              // Stall: hold register contents
    input  logic        flush,              // Flush: insert bubble (NOP)

    // ---- EX stage data inputs ----
    input  logic [31:0] ex_alu_result,      // ALU computation result
    input  logic [31:0] ex_rs2_data,        // Store data (rs2, after forwarding)
    input  logic [31:0] ex_pc_plus4,        // PC+4 (for JAL/JALR link)
    input  logic [4:0]  ex_rd_addr,         // Destination register address
    input  logic        ex_zero,            // ALU zero flag (branch compare)

    // ---- EX stage control inputs ----
    input  logic        ex_reg_write,       // Write-back enable
    input  logic        ex_mem_read,        // Data memory read enable
    input  logic        ex_mem_write,       // Data memory write enable
    input  logic [1:0]  ex_wb_sel,          // Write-back mux select
    input  logic        ex_branch,          // Branch instruction flag
    input  logic        ex_jump,            // Jump instruction flag
    input  logic [2:0]  ex_funct3,          // funct3 (load/store width/type)

    // ---- MEM stage data outputs ----
    output logic [31:0] mem_alu_result,
    output logic [31:0] mem_rs2_data,
    output logic [31:0] mem_pc_plus4,
    output logic [4:0]  mem_rd_addr,
    output logic        mem_zero,

    // ---- MEM stage control outputs ----
    output logic        mem_reg_write,
    output logic        mem_mem_read,
    output logic        mem_mem_write,
    output logic [1:0]  mem_wb_sel,
    output logic        mem_branch,
    output logic        mem_jump,
    output logic [2:0]  mem_funct3
);

    // TODO: Hand-code implementation here

endmodule
