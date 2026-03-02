`timescale 1ns/1ps
`include "defs.sv"

module tb_cordic_top();

    // 1. Signals
    logic        clk;
    logic [31:0] angle_in;
    logic [31:0] cos_out;

    // 2. Instantiate the Top Module
    cordic_top dut (
        .clk(clk),
        .angle_in(angle_in),
        .cos_out(cos_out)
    );

    // 3. Clock Generation (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 4. Test Logic
    initial begin
        $display("Starting CORDIC Floating Point Test...");
        
        // --- Test 1: Cos(0) = 1.0 ---
        // 32'h00000000 is 0.0 in Float
        angle_in = 32'h00000000; 
        repeat(`WORDLENGTH + 2) @(posedge clk); 
        $display("Input: 0.0 rad | Output Float: %h (Expected ~3f800000 for 1.0)", cos_out);

        // --- Test 2: Cos(pi/4) = 0.707 ---
        // 32'h3F490FDB is ~0.785398 rad
        angle_in = 32'h3F490FDB; 
        repeat(`WORDLENGTH + 2) @(posedge clk);
        $display("Input: 0.785 rad | Output Float: %h (Expected ~3f3504f3 for 0.707)", cos_out);

        // --- Test 3: Cos(pi/2) = 0.0 ---
        // 32'h3FC90FDB is ~1.57079 rad
        angle_in = 32'h3FC90FDB; 
        repeat(`WORDLENGTH + 2) @(posedge clk);
        $display("Input: 1.570 rad | Output Float: %h (Expected ~00000000 for 0.0)", cos_out);

        #100;
        $display("Test Complete.");
        $finish;
    end

    // Helper: Monitor changes in a waveform-friendly way
    initial begin
        $dumpfile("cordic_sim.vcd");
        $dumpvars(0, tb_cordic_top);
    end

endmodule