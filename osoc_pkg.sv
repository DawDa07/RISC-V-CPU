// osoc_pkg.sv
package osoc_pkg;

  // Define the Write-Back Multiplexer Selection options
  typedef enum logic [1:0] {
    SEL_ALU = 2'b00,
    SEL_LAU = 2'b01,
    SEL_PC4 = 2'b10
  } wb_sel_e;

endpackage
