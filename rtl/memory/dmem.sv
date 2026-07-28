//==============================================================================
// Module: dmem
// Description: Data memory (synchronous SRAM model) with byte-enable writes.
//              Supports LB/LH/LW/LBU/LHU and SB/SH/SW via the byte-enable bus.
//==============================================================================

module dmem #(
    parameter int unsigned DEPTH = 1024,            // Number of 32-bit words
    parameter int unsigned ADDR_WIDTH = $clog2(DEPTH)
) (
    input  logic                    clk,            // System clock
    input  logic                    rst_n,          // Active-low reset

    input  logic [31:0]             addr,           // Byte address
    input  logic [31:0]             wdata,          // Write data
    input  logic                    we,             // Write enable
    input  logic                    re,             // Read enable
    input  logic [3:0]             be,             // Byte-enable strobe
    output logic [31:0]             rdata           // Read data (word-aligned)
);

    // TODO: Hand-code implementation here

endmodule
