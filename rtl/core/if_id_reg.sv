//==============================================================================
// Module: if_id_reg
// Description: IF/ID pipeline register.
//              Latches instruction and PC from Fetch into Decode.
//==============================================================================

module if_id_reg (
    input  logic        clk,            // System clock
    input  logic        rst_n,          // Active-low asynchronous reset
    input  logic        stall,          // Stall: hold register contents
    input  logic        flush,          // Flush: insert bubble (NOP)

    // ---- IF stage inputs ----
    input  logic [31:0] if_pc,          // PC of fetched instruction
    input  logic [31:0] if_instr,       // Fetched instruction word

    // ---- ID stage outputs ----
    output logic [31:0] id_pc,          // PC forwarded to Decode
    output logic [31:0] id_instr        // Instruction forwarded to Decode
);

    // TODO: Hand-code implementation here

endmodule
