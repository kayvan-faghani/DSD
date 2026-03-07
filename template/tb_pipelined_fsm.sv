`timescale 1ns/1ps
`include "defs.sv"

module tb_pipelined_fsm;

    // -------------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------------
    logic        clk;
    logic        clk_en;
    logic        reset;
    logic [31:0] x;
    logic [31:0] y;

    // -------------------------------------------------------------------------
    // Clock: 10ns period
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // DUT
    // -------------------------------------------------------------------------
    pipelined_fsm dut (
        .clk    (clk),
        .clk_en (clk_en),
        .reset  (reset),
        .x      (x),
        .y      (y)
    );

    // -------------------------------------------------------------------------
    // Pipeline fill latency:
    // CORDIC_STAGES + fp_mul_1 (2) + fp_half (0) + fp_mul_2 (2) = CORDIC_STAGES+4
    // -------------------------------------------------------------------------
    localparam int FILL_LATENCY = `CORDIC_STAGES + 4;

    // -------------------------------------------------------------------------
    // Float helpers
    // -------------------------------------------------------------------------
    function automatic logic [31:0] f2b(input shortreal f);
        return $shortrealtobits(f);
    endfunction

    function automatic shortreal b2f(input logic [31:0] b);
        return $bitstoshortreal(b);
    endfunction

    // -------------------------------------------------------------------------
    // Reference: f(x) = x * (0.5 + x^2 * cos((x-128)/128))
    // -------------------------------------------------------------------------
    function automatic real ref_f(input real xr);
        return xr * (0.5 + xr*xr*$cos((xr-128.0)/128.0));
    endfunction

    // -------------------------------------------------------------------------
    // Test vector storage
    // -------------------------------------------------------------------------
    localparam int N = 64;
    logic [31:0] x_vec   [0:N-1];
    real         ref_vec [0:N-1];
    int          pass_count, fail_count;

    // -------------------------------------------------------------------------
    // Generate test vectors: integers 0..N-1
    // -------------------------------------------------------------------------
    initial begin
        for (int i = 0; i < N; i++) begin
            x_vec[i]   = f2b(shortreal'(i));
            ref_vec[i] = ref_f(real'(i));
        end
    end

    // -------------------------------------------------------------------------
    // Main stimulus
    // -------------------------------------------------------------------------
    initial begin
        pass_count = 0;
        fail_count = 0;

        $dumpfile("tb_pipelined_fsm.vcd");
        $dumpvars(0, tb_pipelined_fsm);

        // Reset
        clk_en = 0;
        reset  = 1;
        x      = 0;
        repeat (4) @(posedge clk);
        @(negedge clk);
        reset  = 0;
        clk_en = 1;

        // ---- Test 1: Stream N inputs, check outputs after fill latency ----
        $display("\n-- Streaming %0d inputs --", N);

        // Feed all N inputs one per cycle
        for (int i = 0; i < N; i++) begin
            @(negedge clk);
            x = x_vec[i];
        end

        // Wait for pipeline to drain (fill latency more cycles)
        repeat (FILL_LATENCY) @(posedge clk);

        // ---- Test 2: Check outputs cycle by cycle ----
        // Reset and re-run, capturing outputs this time
        @(negedge clk);
        clk_en = 0;
        reset  = 1;
        repeat (4) @(posedge clk);
        @(negedge clk);
        reset  = 0;
        clk_en = 1;

        $display("\n-- Checking per-element outputs --");
        fork
            // Feed inputs
            begin
                for (int i = 0; i < N; i++) begin
                    @(negedge clk);
                    x = x_vec[i];
                end
            end
            // Check outputs after fill latency
            begin
                // Wait for first valid output
                repeat (FILL_LATENCY + 1) @(posedge clk);
                for (int i = 0; i < N; i++) begin
                    @(posedge clk);
                    #1;
							begin
								 automatic real got      = real'(b2f(y));
								 automatic real expected = ref_vec[i];
								 automatic real err      = (expected != 0.0) ? 
																	((got-expected)/expected)*100.0 :
																	got - expected;
								 if ($abs(err) < 2.0) begin
									  $display("PASS | x=%6.2f | expected=%e | got=%e | err=%.4f%%",
												  real'(b2f(x_vec[i])), expected, got, err);
									  pass_count++;
								 end else begin
									  $display("FAIL | x=%6.2f | expected=%e | got=%e | err=%.4f%%",
												  real'(b2f(x_vec[i])), expected, got, err);
									  fail_count++;
								 end
							end
                end
            end
        join

        // ---- Test 3: clk_en deassert mid-stream ----
        $display("\n-- clk_en deassert test --");
        @(negedge clk);
        reset  = 1;
        clk_en = 0;
        repeat (4) @(posedge clk);
        @(negedge clk);
        reset  = 0;
        clk_en = 1;
        x      = x_vec[10];

        // Run 5 cycles then deassert clk_en for 3 cycles
        repeat (5) @(posedge clk);
        @(negedge clk);
        clk_en = 0;
        repeat (3) @(posedge clk);
        @(negedge clk);
        clk_en = 1;

        // Continue to drain
        repeat (FILL_LATENCY) @(posedge clk);
        $display("clk_en deassert test complete - verify no corruption in waveform");

        // ---- Summary ----
        $display("\n========================================");
        $display("Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("========================================");

        $finish;
    end

    // -------------------------------------------------------------------------
    // Timeout watchdog
    // -------------------------------------------------------------------------
    initial begin
        #1000000;
        $display("TIMEOUT");
        $finish;
    end

    // -------------------------------------------------------------------------
    // Pipeline monitor - print y every cycle when clk_en high
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (clk_en && !reset)
            $display("  t=%0t | x=%e | y=%e", $time, real'(b2f(x)), real'(b2f(y)));
    end

endmodule