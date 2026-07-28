//==============================================================================
// Module: mem_wb_reg
// Description: MEM/WB pipeline register.
//              Latches memory read data and ALU results from Memory into
//              Write-Back.
//==============================================================================

module mem_wb_reg (
    input  logic        clk,                // System clock
    input  logic        rst_n,              // Active-low asynchronous reset
    input  logic        stall,              // Stall: hold register contents
    input  logic        flush,              // Flush: insert bubble (NOP)

    // ---- MEM stage data inputs ----
    input  logic [31:0] mem_alu_result,     // ALU result (or address)
    input  logic [31:0] mem_rdata,          // Data memory read data
    input  logic [31:0] mem_pc_plus4,       // PC+4 (for JAL/JALR link)
    input  logic [4:0]  mem_rd_addr,        // Destination register address

    // ---- MEM stage control inputs ----
    input  logic        mem_reg_write,      // Write-back enable
    input  logic [1:0]  mem_wb_sel,         // Write-back mux select

    // ---- WB stage data outputs ----
    output logic [31:0] wb_alu_result,
    output logic [31:0] wb_rdata,
    output logic [31:0] wb_pc_plus4,
    output logic [4:0]  wb_rd_addr,

    // ---- WB stage control outputs ----
    output logic        wb_reg_write,
    output logic [1:0]  wb_wb_sel
);

    // TODO: Hand-code implementation here

endmodule
