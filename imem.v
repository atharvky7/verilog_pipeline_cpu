`timescale 1ns/1ps
// imem.v
// Simple instruction memory, 256 x 32-bit, read-only

module imem (
    input  wire [31:0] addr,   // byte address from PC
    output wire [31:0] instr   // instruction word
);

    reg [31:0] mem [0:255];
    integer i;

    initial begin
        // Default: all NOP (0)
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;

        // TODO: later you can hardcode instructions here OR use:
        // $readmemh("program.hex", mem);
    end

    // word addressing: ignore low 2 bits
    assign instr = mem[addr[9:2]];

endmodule
