`timescale 1ns/1ps

module nand_tb;

    logic a, b, y;

    nand_gate dut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        $dumpfile("nand_test.vcd");
        $dumpvars(0, nand_tb);

        a = 0; b = 0; #10;  // expect y = 1
        a = 0; b = 1; #10;  // expect y = 1
        a = 1; b = 0; #10;  // expect y = 1
        a = 1; b = 1; #10;  // expect y = 0

        $display("a=%0b b=%0b y=%0b", a, b, y);
        $finish;
    end

endmodule
