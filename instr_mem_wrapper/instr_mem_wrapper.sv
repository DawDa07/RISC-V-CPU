module instr_mem_wrapper #(
    parameter int DEPTH = 1024
)(
    // =========================================================================
    // CPU-Facing Interface
    // =========================================================================
`ifdef USE_OPENRAM
    input  logic        clk_i,
`endif
    input  logic [31:0] pc_i,
    output logic [31:0] instr_o
);

`ifdef USE_OPENRAM

    // Physical Design: OpenRAM Instantiation (read-only instruction fetch)
    logic csb0;
    logic web0;

    assign csb0 = 1'b0;
    assign web0 = 1'b1;  // Always read

    sram_4kb_32b_openram u_physical_macro (
        .clk0   (clk_i),
        .csb0   (csb0),
        .web0   (web0),
        .wmask0 (4'b0000),
        .addr0  (pc_i[11:2]),
        .din0   (32'h00000000),
        .dout0  (instr_o)
    );

`else

    // Simulation: Behavioral Model Instantiation
    instr_mem_behavioral #(
        .DEPTH(DEPTH)
    ) u_behav_macro (
        .pc_i    (pc_i),
        .instr_o (instr_o)
    );

`endif

endmodule
