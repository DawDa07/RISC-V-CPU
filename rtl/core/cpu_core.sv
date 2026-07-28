//==============================================================================
// Module: cpu_core
// Description: Top-level RV32I 5-stage pipelined CPU core wrapper.
//              Instantiates and interconnects: PC, pipeline registers,
//              regfile, imm_gen, ALU, control, hazard, and forwarding units.
//              Instruction and data memories are external (SoC level).
//==============================================================================

module cpu_core (
    input  logic        clk,                // System clock
    input  logic        rst_n,              // Active-low asynchronous reset

    // ---- Instruction memory interface ----
    output logic [31:0] imem_addr,          // Instruction fetch address
    input  logic [31:0] imem_rdata,         // Instruction word from IMEM

    // ---- Data memory interface ----
    output logic [31:0] dmem_addr,          // Data memory address
    output logic [31:0] dmem_wdata,         // Data memory write data
    output logic        dmem_we,            // Data memory write enable
    output logic        dmem_re,            // Data memory read enable
    output logic [3:0]  dmem_be,            // Byte-enable strobe
    input  logic [31:0] dmem_rdata,         // Data memory read data

    // ---- Debug / status (optional observability) ----
    output logic [31:0] debug_pc,           // Current PC (IF stage)
    output logic        debug_halted        // Halted on EBREAK / illegal
);

    // TODO: Hand-code implementation here
    // Instantiate and wire: pc_reg, if_id_reg, id_ex_reg, ex_mem_reg,
    // mem_wb_reg, regfile, imm_gen, alu, control_unit, hazard_unit,
    // forwarding, plus combinatorial muxes for PC next, ALU operands,
    // branch target, and write-back data.

endmodule
