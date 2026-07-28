//==============================================================================
// Module: forwarding
// Description: Forwarding / bypassing unit.
//              Resolves data hazards by selecting ALU operands from EX/MEM or
//              MEM/WB results instead of the register file.
//==============================================================================

module forwarding (
    // ---- EX stage source registers ----
    input  logic [4:0]  ex_rs1_addr,        // rs1 address in EX
    input  logic [4:0]  ex_rs2_addr,        // rs2 address in EX

    // ---- MEM stage destination ----
    input  logic        mem_reg_write,      // MEM stage will write a register
    input  logic [4:0]  mem_rd_addr,        // MEM destination register

    // ---- WB stage destination ----
    input  logic        wb_reg_write,       // WB stage will write a register
    input  logic [4:0]  wb_rd_addr,         // WB destination register

    // ---- Forward select outputs ----
    //   2'b00 = use register file / EX pipeline value
    //   2'b01 = forward from MEM stage (EX/MEM ALU result)
    //   2'b10 = forward from WB stage (MEM/WB result)
    output logic [1:0]  forward_a,          // Operand A forward select
    output logic [1:0]  forward_b           // Operand B forward select
);

    // TODO: Hand-code implementation here

endmodule
