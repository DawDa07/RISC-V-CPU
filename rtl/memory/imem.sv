//==============================================================================
// Module: imem
// Description: Instruction memory (synchronous SRAM model).
//              Read-only from the CPU perspective; contents are loaded at
//              simulation start via $readmemh or a DPI/Verilator backdoor.
//==============================================================================

module imem #(
    parameter int unsigned DEPTH = 1024,            // Number of 32-bit words
    parameter int unsigned ADDR_WIDTH = $clog2(DEPTH)
) (
    input  logic                    clk,            // System clock
    input  logic [31:0]             addr,           // Byte address from CPU
    output logic [31:0]             rdata,          // Instruction word

    // ---- Simulation backdoor load (optional) ----
    input  logic                    load_en,        // Pulse to write one word
    input  logic [ADDR_WIDTH-1:0]   load_addr,      // Word address for load
    input  logic [31:0]             load_data       // Word data for load
);

    // TODO: Hand-code implementation here

endmodule
