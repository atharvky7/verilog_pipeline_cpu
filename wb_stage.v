`timescale 1ns/1ps
// wb_stage.v
// Write-back stage: select between ALU result and memory data

module wb_stage (
    input  wire        mem_to_reg,
    input  wire [31:0] read_data,
    input  wire [31:0] alu_result,
    output wire [31:0] write_data
);

    assign write_data = mem_to_reg ? read_data : alu_result;

endmodule
