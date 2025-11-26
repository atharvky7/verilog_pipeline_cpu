`timescale 1ns/1ps
// ex_stage.v
// Execute stage: ALU, branch target computation, forwarding

module ex_stage (
    input  wire [31:0] pc_plus4,
    input  wire [31:0] rd1_in,
    input  wire [31:0] rd2_in,
    input  wire [31:0] sign_ext_imm,
    input  wire [4:0]  rs,
    input  wire [4:0]  rt,
    input  wire [4:0]  rd,
    input  wire        reg_dst,
    input  wire        alu_src,
    input  wire [2:0]  alu_ctrl,
    // forwarding inputs
    input  wire [1:0]  forward_a,
    input  wire [1:0]  forward_b,
    input  wire [31:0] ex_mem_alu_result,
    input  wire [31:0] mem_wb_write_data,
    // outputs
    output wire [31:0] branch_target,
    output wire [31:0] alu_result,
    output wire [31:0] write_data,     // value sent to MEM for SW
    output wire        zero,
    output wire [4:0]  write_reg_out,  // destination register
    output wire [4:0]  rs_out,
    output wire [4:0]  rt_out
);

    // pass-through for hazard unit (if needed)
    assign rs_out = rs;
    assign rt_out = rt;

    // forwarding muxes
    reg [31:0] alu_in1;
    reg [31:0] alu_in2_pre;
    reg [31:0] rd2_forwarded;

    always @* begin
        // Forward A
        case (forward_a)
            2'b00: alu_in1 = rd1_in;
            2'b10: alu_in1 = ex_mem_alu_result;
            2'b01: alu_in1 = mem_wb_write_data;
            default: alu_in1 = rd1_in;
        endcase

        // Forward B (used for ALU and write_data)
        case (forward_b)
            2'b00: rd2_forwarded = rd2_in;
            2'b10: rd2_forwarded = ex_mem_alu_result;
            2'b01: rd2_forwarded = mem_wb_write_data;
            default: rd2_forwarded = rd2_in;
        endcase

        alu_in2_pre = rd2_forwarded;
    end

    // ALU second input selection (register vs immediate)
    wire [31:0] alu_in2 = alu_src ? sign_ext_imm : alu_in2_pre;

    // branch target: PC+4 + (imm << 2)
    assign branch_target = pc_plus4 + (sign_ext_imm << 2);

    // destination register
    assign write_reg_out = reg_dst ? rd : rt;

    // ALU instance
    alu ALU (
        .a       (alu_in1),
        .b       (alu_in2),
        .alu_ctrl(alu_ctrl),
        .result  (alu_result),
        .zero    (zero)
    );

    // data to write to memory
    assign write_data = rd2_forwarded;

endmodule
