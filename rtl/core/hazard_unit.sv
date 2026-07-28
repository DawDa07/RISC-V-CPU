//==============================================================================
// Module: hazard_unit
// Description: Hazard detection unit.
//              Detects load-use data hazards and control hazards; generates
//              stall and flush signals for the pipeline.
//==============================================================================

module hazard_unit (
    // ---- Decode-stage source registers ----
    input  logic [4:0]  id_rs1_addr,        // rs1 in ID
    input  logic [4:0]  id_rs2_addr,        // rs2 in ID

    // ---- Execute-stage (potential load) ----
    input  logic        ex_mem_read,        // EX stage is a load
    input  logic [4:0]  ex_rd_addr,         // EX destination register

    // ---- Branch / jump taken (control hazard) ----
    input  logic        branch_taken,       // Branch resolved as taken
    input  logic        jump_taken,         // Jump in progress

    // ---- Stall outputs ----
    output logic        stall_if,           // Stall IF stage (hold PC)
    output logic        stall_id,           // Stall IF/ID register

    // ---- Flush outputs ----
    output logic        flush_if_id,        // Squash IF/ID (control hazard)
    output logic        flush_id_ex         // Squash ID/EX (load-use bubble)
);

    // TODO: Hand-code implementation here

endmodule
