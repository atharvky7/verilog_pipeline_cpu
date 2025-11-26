`timescale 1ns/1ps
// if_stage.v
// Instruction Fetch stage: PC register, PC+4, instruction memory

module if_stage (
    input  wire        clk,
    input  wire        reset,
    input  wire        pc_write,        // from hazard unit
    input  wire        branch_taken,    // from EX/MEM
    input  wire [31:0] branch_target,   // from EX stage
    output reg  [31:0] pc,
    output wire [31:0] pc_plus4,
    output wire [31:0] instr
);

    wire [31:0] pc_next;

    assign pc_plus4 = pc + 32'd4;
    assign pc_next  = branch_taken ? branch_target : pc_plus4;

    // PC register
    always @(posedge clk) begin
        if (reset) begin
            pc <= 32'b0;
        end else if (pc_write) begin
            pc <= pc_next;
        end
    end

    // Instruction memory
    imem IMEM (
        .addr (pc),
        .instr(instr)
    );

endmodule
