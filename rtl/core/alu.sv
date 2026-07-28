//==============================================================================
// Module: alu
// Description: Arithmetic Logic Unit for RV32I.
//              Performs arithmetic, logical, and comparison operations.
//==============================================================================

module alu (
    input  logic [31:0] op_a,           // Operand A (typically rs1)
    input  logic [31:0] op_b,           // Operand B (rs2 or immediate)
    input  logic [3:0]  alu_op,         // Operation select
                                        //   4'b0000 = ADD
                                        //   4'b0001 = SUB
                                        //   4'b0010 = AND
                                        //   4'b0011 = OR
                                        //   4'b0100 = XOR
                                        //   4'b0101 = SLL
                                        //   4'b0110 = SRL
                                        //   4'b0111 = SRA
                                        //   4'b1000 = SLT  (signed)
                                        //   4'b1001 = SLTU (unsigned)
    output logic [31:0] result,         // ALU result
    output logic        zero            // Result == 0 flag (for branches)
);

    // TODO: Hand-code implementation here

endmodule
