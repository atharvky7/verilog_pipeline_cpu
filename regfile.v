`timescale 1ns/1ps
// regfile.v
// 32x32 register file, 2 read ports, 1 write port

module regfile (
    input  wire        clk,
    input  wire        we,         // write enable
    input  wire [4:0]  ra1,        // read address 1
    input  wire [4:0]  ra2,        // read address 2
    input  wire [4:0]  wa,         // write address
    input  wire [31:0] wd,         // write data
    output wire [31:0] rd1,        // read data 1
    output wire [31:0] rd2         // read data 2
);

    reg [31:0] regs [0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (we && (wa != 5'd0)) begin
            regs[wa] <= wd;
        end
    end

    assign rd1 = (ra1 == 5'd0) ? 32'b0 : regs[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'b0 : regs[ra2];

endmodule
