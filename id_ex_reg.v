`timescale 1ns/1ps
// id_ex_reg.v
// ID/EX pipeline register

module id_ex_reg (
    input  wire        clk,
    input  wire        reset,
    input  wire        flush,     // used for load-use bubble (zero control)
    // control signals
    input  wire        reg_dst_in,
    input  wire        alu_src_in,
    input  wire        mem_to_reg_in,
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        branch_in,
    input  wire [2:0]  alu_ctrl_in,
    // data
    input  wire [31:0] pc_plus4_in,
    input  wire [31:0] rd1_in,
    input  wire [31:0] rd2_in,
    input  wire [31:0] sign_ext_imm_in,
    input  wire [4:0]  rs_in,
    input  wire [4:0]  rt_in,
    input  wire [4:0]  rd_in,
    // outputs
    output reg         reg_dst_out,
    output reg         alu_src_out,
    output reg         mem_to_reg_out,
    output reg         reg_write_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         branch_out,
    output reg [2:0]   alu_ctrl_out,
    output reg [31:0]  pc_plus4_out,
    output reg [31:0]  rd1_out,
    output reg [31:0]  rd2_out,
    output reg [31:0]  sign_ext_imm_out,
    output reg [4:0]   rs_out,
    output reg [4:0]   rt_out,
    output reg [4:0]   rd_out
);

    always @(posedge clk) begin
        if (reset) begin
            reg_dst_out      <= 1'b0;
            alu_src_out      <= 1'b0;
            mem_to_reg_out   <= 1'b0;
            reg_write_out    <= 1'b0;
            mem_read_out     <= 1'b0;
            mem_write_out    <= 1'b0;
            branch_out       <= 1'b0;
            alu_ctrl_out     <= 3'b000;
            pc_plus4_out     <= 32'b0;
            rd1_out          <= 32'b0;
            rd2_out          <= 32'b0;
            sign_ext_imm_out <= 32'b0;
            rs_out           <= 5'b0;
            rt_out           <= 5'b0;
            rd_out           <= 5'b0;
        end else begin
            if (flush) begin
                // bubble: zero control signals
                reg_dst_out    <= 1'b0;
                alu_src_out    <= 1'b0;
                mem_to_reg_out <= 1'b0;
                reg_write_out  <= 1'b0;
                mem_read_out   <= 1'b0;
                mem_write_out  <= 1'b0;
                branch_out     <= 1'b0;
                alu_ctrl_out   <= 3'b000;
            end else begin
                reg_dst_out    <= reg_dst_in;
                alu_src_out    <= alu_src_in;
                mem_to_reg_out <= mem_to_reg_in;
                reg_write_out  <= reg_write_in;
                mem_read_out   <= mem_read_in;
                mem_write_out  <= mem_write_in;
                branch_out     <= branch_in;
                alu_ctrl_out   <= alu_ctrl_in;
            end

            pc_plus4_out     <= pc_plus4_in;
            rd1_out          <= rd1_in;
            rd2_out          <= rd2_in;
            sign_ext_imm_out <= sign_ext_imm_in;
            rs_out           <= rs_in;
            rt_out           <= rt_in;
            rd_out           <= rd_in;
        end
    end

endmodule
