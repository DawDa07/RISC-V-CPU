//==============================================================================
// Module: uart_tx
// Description: Memory-mapped UART transmitter peripheral.
//              Simple 8N1 TX with a status/data register interface for
//              printf-style debug output from bare-metal software.
//
// Memory map (relative to base address, typically 0x1000_0000):
//   +0x00  DATA   WO  Write byte to transmit
//   +0x04  STATUS RO  bit0 = TX busy
//==============================================================================

module uart_tx #(
    parameter int unsigned CLOCK_HZ = 50_000_000,
    parameter int unsigned BAUD     = 115200
) (
    input  logic        clk,            // System clock
    input  logic        rst_n,          // Active-low asynchronous reset

    // ---- Memory-mapped bus ----
    input  logic        sel,            // Chip select (address decode)
    input  logic [3:0]  addr,           // Register offset (byte address [3:0])
    input  logic        we,             // Write enable
    input  logic [31:0] wdata,          // Write data
    output logic [31:0] rdata,          // Read data

    // ---- Serial pin ----
    output logic        tx              // UART TX line (idle high)
);

    // TODO: Hand-code implementation here

endmodule
