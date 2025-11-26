`timescale 1ns/1ps
// dmem.v
// Simple data memory, 256 x 32-bit, for LW/SW

module dmem (
    input  wire        clk,
    input  wire        mem_we,     // write enable
    input  wire [31:0] addr,       // byte address
    input  wire [31:0] wd,         // write data
    output wire [31:0] rd          // read data
);

    reg [31:0] mem [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;
    end

    wire [7:0] word_addr = addr[9:2]; // word address

    always @(posedge clk) begin
        if (mem_we) begin
            mem[word_addr] <= wd;
        end
    end

    assign rd = mem[word_addr];

endmodule
