`timescale 1ns/1ps
// alu.v
// Simple 32-bit ALU for ADD, SUB, AND, OR

module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_ctrl,   // 000=ADD, 001=SUB, 010=AND, 011=OR
    output reg  [31:0] result,
    output wire        zero
);

    always @* begin
        case (alu_ctrl)
            3'b000: result = a + b;        // ADD
            3'b001: result = a - b;        // SUB
            3'b010: result = a & b;        // AND
            3'b011: result = a | b;        // OR
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
