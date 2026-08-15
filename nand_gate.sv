// nand_gate.sv
module nand_gate (
    input  logic a,
    input  logic b,
    output logic y
);

    // Simple NAND logic
    assign y = ~(a & b);

endmodule
