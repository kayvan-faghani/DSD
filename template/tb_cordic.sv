`include "defs.sv"


module tb_cordic();
    logic clk=0;
    logic [`WORDLENGTH-1:0] angle_in, cos_out;
	 logic  [`CORDIC_STAGES:0] [`WORDLENGTH-1:0] x_array_out, y_array_out, z_array_out;
    localparam real SCALE = 2.0**20;

    cordic dut (.*);

    initial begin
        $display("Testing range -1.0 to 1.0 Radians...");
        $display("Input (Rad) | Expected Cos | CORDIC Cos | Error");
        
        // Test -1.0 Radians
        run_test(-1.0);
        // Test 0.5 Radians
        run_test(0.5);
        // Test 1.0 Radians
        run_test(1.0);
        
        $finish;
    end

    task run_test(input real rad);
        real expected;
        // Step 1: Real math
        // Step 2: Cast to integer (longint) 
        // Step 3: Size cast to 22 bits
        angle_in = (`WORDLENGTH)'( longint'(rad * SCALE) );
        
        expected = $cos(rad);
        #10; 
        
        $display("%10.2f | %12.6f | %10.6f", 
                 rad, expected, real'($signed(cos_out))/SCALE);
    endtask
endmodule