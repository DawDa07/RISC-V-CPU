//==============================================================================
// Module: regfile
// Description: 32 x 32-bit RISC-V integer register file.
//              Dual asynchronous read ports, one synchronous write port.
//              x0 is hardwired to zero (writes ignored, reads always 0).
//==============================================================================

module regfile (
    input  logic        clk,            // System clock
    input  logic        rst_n,          // Active-low asynchronous reset

    // ---- Write port (WB stage) ----
    input  logic        rd_we,          // Write enable
    input  logic [4:0]  rd_addr,        // Destination register address
    input  logic [31:0] rd_wdata,       // Write data

    // ---- Read port 1 (ID stage) ----
    input  logic [4:0]  rs1_addr,       // Source register 1 address
    output logic [31:0] rs1_rdata,      // Source register 1 read data

    // ---- Read port 2 (ID stage) ----
    input  logic [4:0]  rs2_addr,       // Source register 2 address
    output logic [31:0] rs2_rdata       // Source register 2 read data
);

    // TODO: Hand-code implementation here

endmodule
