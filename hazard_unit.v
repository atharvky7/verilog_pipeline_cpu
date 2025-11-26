`timescale 1ns/1ps
// hazard_unit.v
// Detect load-use hazard and generate stall / control-stall signals

module hazard_unit (
    input  wire        id_ex_mem_read,  // ID/EX.MemRead
    input  wire [4:0]  id_ex_rt,        // ID/EX.Rt (load dest)
    input  wire [4:0]  if_id_rs,        // IF/ID.Rs
    input  wire [4:0]  if_id_rt,        // IF/ID.Rt
    output reg         pc_write,
    output reg         if_id_write,
    output reg         control_stall    // 1 => zero control signals (insert bubble)
);

    always @* begin
        // default: no stall
        pc_write      = 1'b1;
        if_id_write   = 1'b1;
        control_stall = 1'b0;

        if (id_ex_mem_read &&
           ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt)) &&
           (id_ex_rt != 5'd0)) begin
            // load-use hazard: stall
            pc_write      = 1'b0;
            if_id_write   = 1'b0;
            control_stall = 1'b1;
        end
    end

endmodule
