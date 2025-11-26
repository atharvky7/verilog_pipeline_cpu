`timescale 1ns/1ps
// id_stage.v
// Instruction Decode stage: register file read and immediate generation

module id_stage (
    input  wire        clk,
    input  wire [31:0] instr,
    input  wire [31:0] pc_plus4_in,
    // write-back interface
    input  wire        wb_reg_write,
    input  wire [4:0]  wb_write_reg,
    input  wire [31:0] wb_write_data,
    // outputs
    output wire [31:0] rd1,
    output wire [31:0] rd2,
    output wire [31:0] sign_ext_imm,
    output wire [4:0]  rs,
    output wire [4:0]  rt,
    output wire [4:0]  rd,
    output wire [31:0] pc_plus4_out
);

    assign rs = instr[25:21];
    assign rt = instr[20:16];
    assign rd = instr[15:11];

    // sign extension of 16-bit immediate
    assign sign_ext_imm = {{16{instr[15]}}, instr[15:0]};

    assign pc_plus4_out = pc_plus4_in;

    // register file
    regfile RF (
        .clk (clk),
        .we  (wb_reg_write),
        .ra1 (rs),
        .ra2 (rt),
        .wa  (wb_write_reg),
        .wd  (wb_write_data),
        .rd1 (rd1),
        .rd2 (rd2)
    );

endmodule
