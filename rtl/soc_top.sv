//==============================================================================
// Module: soc_top
// Description: System-on-Chip top-level.
//              Connects the RV32I CPU core to instruction memory, data memory,
//              and a memory-mapped UART TX peripheral.
//
// Address map:
//   0x0000_0000 – 0x0000_FFFF  Instruction / data RAM (unified for sim)
//   0x1000_0000 – 0x1000_000F  UART TX registers
//==============================================================================

module soc_top (
    input  logic        clk,            // System clock
    input  logic        rst_n,          // Active-low asynchronous reset

    // ---- External UART ----
    output logic        uart_tx,        // UART transmit pin

    // ---- IMEM backdoor load (simulation / Verilator) ----
    input  logic        imem_load_en,
    input  logic [9:0]  imem_load_addr,
    input  logic [31:0] imem_load_data,

    // ---- Debug ----
    output logic [31:0] debug_pc,
    output logic        debug_halted
);

    //--------------------------------------------------------------------------
    // Internal interconnect
    //--------------------------------------------------------------------------
    logic [31:0] imem_addr;
    logic [31:0] imem_rdata;

    logic [31:0] dmem_addr;
    logic [31:0] dmem_wdata;
    logic        dmem_we;
    logic        dmem_re;
    logic [3:0]  dmem_be;
    logic [31:0] dmem_rdata_raw;
    logic [31:0] dmem_rdata;

    logic        uart_sel;
    logic [31:0] uart_rdata;

    //--------------------------------------------------------------------------
    // Address decode: UART at 0x1000_0000
    //--------------------------------------------------------------------------
    assign uart_sel = (dmem_addr[31:28] == 4'h1);

    // Mux read data: UART vs data memory
    assign dmem_rdata = uart_sel ? uart_rdata : dmem_rdata_raw;

    //--------------------------------------------------------------------------
    // CPU Core
    //--------------------------------------------------------------------------
    cpu_core u_cpu (
        .clk         (clk),
        .rst_n       (rst_n),
        .imem_addr   (imem_addr),
        .imem_rdata  (imem_rdata),
        .dmem_addr   (dmem_addr),
        .dmem_wdata  (dmem_wdata),
        .dmem_we     (dmem_we),
        .dmem_re     (dmem_re),
        .dmem_be     (dmem_be),
        .dmem_rdata  (dmem_rdata),
        .debug_pc    (debug_pc),
        .debug_halted(debug_halted)
    );

    //--------------------------------------------------------------------------
    // Instruction Memory
    //--------------------------------------------------------------------------
    imem #(
        .DEPTH(1024)
    ) u_imem (
        .clk       (clk),
        .addr      (imem_addr),
        .rdata     (imem_rdata),
        .load_en   (imem_load_en),
        .load_addr (imem_load_addr),
        .load_data (imem_load_data)
    );

    //--------------------------------------------------------------------------
    // Data Memory (disabled when UART is selected)
    //--------------------------------------------------------------------------
    dmem #(
        .DEPTH(1024)
    ) u_dmem (
        .clk   (clk),
        .rst_n (rst_n),
        .addr  (dmem_addr),
        .wdata (dmem_wdata),
        .we    (dmem_we & ~uart_sel),
        .re    (dmem_re & ~uart_sel),
        .be    (dmem_be),
        .rdata (dmem_rdata_raw)
    );

    //--------------------------------------------------------------------------
    // UART TX Peripheral
    //--------------------------------------------------------------------------
    uart_tx #(
        .CLOCK_HZ(50_000_000),
        .BAUD    (115200)
    ) u_uart (
        .clk   (clk),
        .rst_n (rst_n),
        .sel   (uart_sel),
        .addr  (dmem_addr[3:0]),
        .we    (dmem_we & uart_sel),
        .wdata (dmem_wdata),
        .rdata (uart_rdata),
        .tx    (uart_tx)
    );

endmodule
