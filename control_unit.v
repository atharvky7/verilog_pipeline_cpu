`timescale 1ns/1ps
// control_unit.v
// Main control logic + ALU control (combined)

module control_unit (
    input  wire [5:0] opcode,
    input  wire [5:0] funct,
    output reg        reg_dst,
    output reg        alu_src,
    output reg        mem_to_reg,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        branch,
    output reg [2:0]  alu_ctrl  // to ALU
);

    always @* begin
        // default
        reg_dst    = 1'b0;
        alu_src    = 1'b0;
        mem_to_reg = 1'b0;
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        alu_ctrl   = 3'b000; // default ADD

        case (opcode)
            6'b000000: begin
                // R-type: use funct
                reg_dst   = 1'b1;
                reg_write = 1'b1;
                case (funct)
                    6'b100000: alu_ctrl = 3'b000; // ADD
                    6'b100010: alu_ctrl = 3'b001; // SUB
                    6'b100100: alu_ctrl = 3'b010; // AND
                    6'b100101: alu_ctrl = 3'b011; // OR
                    default:   alu_ctrl = 3'b000;
                endcase
            end
            6'b100011: begin
                // LW
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_ctrl   = 3'b000; // ADD for address
            end
            6'b101011: begin
                // SW
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_ctrl  = 3'b000; // ADD for address
            end
            6'b000100: begin
                // BEQ
                branch   = 1'b1;
                alu_ctrl = 3'b001; // SUB for comparison
            end
            default: begin
                // NOP / unsupported
            end
        endcase
    end

endmodule
