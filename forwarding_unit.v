`timescale 1ns/1ps
// forwarding_unit.v
// Controls forwarding muxes in EX stage

module forwarding_unit (
    input  wire       ex_mem_reg_write,
    input  wire [4:0] ex_mem_rd,
    input  wire       mem_wb_reg_write,
    input  wire [4:0] mem_wb_rd,
    input  wire [4:0] id_ex_rs,
    input  wire [4:0] id_ex_rt,
    output reg [1:0]  forward_a,
    output reg [1:0]  forward_b
);

    always @* begin
        // defaults: no forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;

        // EX hazard
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs)) begin
            forward_a = 2'b10;
        end

        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rt)) begin
            forward_b = 2'b10;
        end

        // MEM hazard
        if (mem_wb_reg_write && (mem_wb_rd != 5'd0) &&
            !(ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs)) &&
            (mem_wb_rd == id_ex_rs)) begin
            forward_a = 2'b01;
        end

        if (mem_wb_reg_write && (mem_wb_rd != 5'd0) &&
            !(ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rt)) &&
            (mem_wb_rd == id_ex_rt)) begin
            forward_b = 2'b01;
        end
    end

endmodule
