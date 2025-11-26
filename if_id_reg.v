`timescale 1ns/1ps
// if_id_reg.v
// IF/ID pipeline register

module if_id_reg (
    input  wire        clk,
    input  wire        reset,
    input  wire        write_en,     // from hazard unit
    input  wire        flush,        // from branch taken
    input  wire [31:0] pc_plus4_in,
    input  wire [31:0] instr_in,
    output reg  [31:0] pc_plus4_out,
    output reg  [31:0] instr_out
);

    always @(posedge clk) begin
        if (reset || flush) begin
            pc_plus4_out <= 32'b0;
            instr_out    <= 32'b0;
        end else if (write_en) begin
            pc_plus4_out <= pc_plus4_in;
            instr_out    <= instr_in;
        end
        // if write_en == 0, hold previous values
    end

endmodule
