//==============================================================================
// Module: control_unit
// Description: Main control decoder and ALU control.
//              Decodes the RV32I opcode / funct fields into datapath control
//              signals for the ID stage.
//==============================================================================

module control_unit (
    input  logic [6:0]  opcode,         // Instruction opcode [6:0]
    input  logic [2:0]  funct3,         // funct3 field [14:12]
    input  logic [6:0]  funct7,         // funct7 field [31:25]

    // ---- Datapath control ----
    output logic        reg_write,      // Register file write enable
    output logic        mem_read,       // Data memory read enable
    output logic        mem_write,      // Data memory write enable
    output logic        alu_src,        // ALU B operand: 0=rs2, 1=imm
    output logic [1:0]  wb_sel,         // Write-back select
                                        //   2'b00 = ALU result
                                        //   2'b01 = Memory read data
                                        //   2'b10 = PC+4 (link)
    output logic [3:0]  alu_op,         // ALU operation code
    output logic [2:0]  imm_sel,        // Immediate format select
    output logic        branch,         // Branch instruction
    output logic        jump,           // Jump (JAL/JALR) instruction
    output logic        pc_src_jalr,    // Use rs1+imm as jump target (JALR)
    output logic        illegal_instr   // Unrecognized opcode flag
);

    // TODO: Hand-code implementation here

endmodule
