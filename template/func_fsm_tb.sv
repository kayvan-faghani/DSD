`timescale 1ns/1ps

module func_fsm_tb();

    // Clock and Reset logic
    logic clk;
    logic reset;
    logic [31:0] x;
    logic [31:0] y;

    // Instantiate UUT
    func_fsm uut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y)
    );

    // Clock Generation: 100 MHz (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // --- 1. Initial Reset ---
        reset = 1;
        x = 0;
        #25;
        reset = 0;

        // --- 2. Test Case 1: x = 128.0 (32'h43000000) ---
        // Expected Logic:
        // (128-128)/128 = 0 radians. cos(0) = 1.0 (32'h3f800000)
        // y = 128 * (0.5 + 128^2 * 1.0) 
        // y = 128 * 16384.5 = 2097216.0
        // Expected Hex: 32'h4A000080
        test_value(32'h43000000, 32'h4A000080, "x = 128.0");

        // --- 3. Test Case 2: x = 130.0 (32'h43020000) ---
        // Expected Logic:
        // (130-128)/128 = 0.015625 rad. cos(0.015625) = 0.9998779 (32'h3F7FF800)
        // y = 130 * (0.5 + 16900 * 0.9998779)
        // y = 130 * 16898.437 = 2196796.8...
        // Expected Hex: ~32'h4A060777 (Approx due to CORDIC precision)
        test_value(32'h43020000, 32'h4A060777, "x = 130.0");

        // --- 4. Test Case 3: x = 0.0 (32'h00000000) ---
        // Expected Logic: y = 0 * (...) = 0.0
        // Expected Hex: 32'h00000000
        test_value(32'h00000000, 32'h00000000, "x = 0.0");

        $display("[%0t] All Test Cases Finished!", $time);
        $stop;
    end

    // Task to apply a value, wait for FSM to cycle, and verify
    task test_value(input [31:0] val, input [31:0] expected, string name);
        begin
            @(posedge clk);
            x = val;
            $display("[%0t] TESTING %s: Input x = %h", $time, name, val);
            
            // Wait for FSM to cycle back to start or reach final multiply state
            // Adjust the 'wait' to match your specific FSM's completion condition
            wait(uut.current_state == uut.MUL_TWO);
            wait(uut.counter == 1); // Just before it captures the final Y
            
            @(posedge clk);
            #1; // Small delay to let 'y' settle
            if (y == expected)
                $display("  SUCCESS: y = %h", y);
            else
                $display("  FAILURE: y = %h (Expected %h) - Difference: %h", y, expected, y ^ expected);
            
            // Allow FSM to transition back to SQUARE_SUBTRACT
            repeat(5) @(posedge clk); 
        end
    endtask

endmodule