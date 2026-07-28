//==============================================================================
// Module: pc_reg
// Description: Program Counter register for the IF stage.
//              Holds the address of the instruction currently being fetched.
//==============================================================================

module pc_reg (
    input  logic        clk,        // System clock
    input  logic        rst_n,      // Active-low asynchronous reset
    input  logic        stall,      // Stall: hold PC when high (hazard)
    input  logic [31:0] pc_next,    // Next PC value (PC+4, branch/jump target)
    output logic [31:0] pc          // Current PC value
);

    // TODO: Hand-code implementation here

endmodule
