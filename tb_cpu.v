`timescale 1ns/1ps
// tb_cpu.v
// Simple testbench for cpu_top

module tb_cpu;

    reg clk;
    reg reset;

    cpu_top DUT (
        .clk   (clk),
        .reset (reset)
    );

    // clock: 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1'b1;
        #20;
        reset = 1'b0;

        // Run for some cycles
        #500;

        $display("Simulation finished.");
        $finish;
    end

endmodule
