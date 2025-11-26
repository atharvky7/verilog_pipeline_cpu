`timescale 1ns/1ps
// mem_stage.v
// Memory access stage: LW/SW via data memory

module mem_stage (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] alu_result_in,
    input  wire [31:0] write_data_in,
    output wire [31:0] read_data_out,
    output wire [31:0] alu_result_out
);

    assign alu_result_out = alu_result_in;

    dmem DMEM (
        .clk    (clk),
        .mem_we (mem_write),
        .addr   (alu_result_in),
        .wd     (write_data_in),
        .rd     (read_data_out)
    );

endmodule
