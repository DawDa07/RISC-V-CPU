module instr_mem_behavioral #(
    parameter int DEPTH = 1024 
)(
    input  logic [31:0] pc_i,
    output logic [31:0] instr_o
);

    // The physical memory array (Word addressed)
    logic [31:0] memory_array [0:DEPTH-1];

    // Zero-fill, then optionally preload firmware.hex when present.
    // CPU cocotb tests backdoor-load programs/*.hex and do not rely on this.
    integer i;
    integer fd;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory_array[i] = 32'h00000000;
        end
        fd = $fopen("firmware.hex", "r");
        if (fd) begin
            $fclose(fd);
            $readmemh("firmware.hex", memory_array);
        end
    end

    // =========================================================================
    // Asynchronous Combinational Fetch
    // =========================================================================
    // Shift PC right by 2 to convert Byte-Address to Word-Address
    wire [29:0] word_addr = pc_i[31:2];

    // Fetch instruction. If PC is out of bounds, return 0 (safe fallback)
    assign instr_o = (word_addr < DEPTH) ? memory_array[word_addr] : 32'h00000000;

endmodule
