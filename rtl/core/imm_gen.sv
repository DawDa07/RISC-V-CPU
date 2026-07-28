//==============================================================================
// Module: imm_gen
// Description: Immediate generator.
//              Extracts and sign-extends immediates for I/S/B/U/J formats
//              based on the instruction opcode.
//==============================================================================

module imm_gen (
    input  logic [31:0] instr,          // Full instruction word
    input  logic [2:0]  imm_sel,        // Immediate format select
                                        //   3'b000 = I-type
                                        //   3'b001 = S-type
                                        //   3'b010 = B-type
                                        //   3'b011 = U-type
                                        //   3'b100 = J-type
    output logic [31:0] imm_out         // Sign-extended 32-bit immediate
);

    // TODO: Hand-code implementation here

endmodule
