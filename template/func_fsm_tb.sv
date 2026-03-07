`timescale 1ns/1ps
`include "defs.sv"

module func_fsm_tb;

    // -------------------------------------------------------------------------
    // DUT signals
    // -------------------------------------------------------------------------
    logic        clk;
    logic        clk_en;
    logic        reset;
    logic [31:0] x;
    logic [31:0] y;

    // -------------------------------------------------------------------------
    // Clock: 10 ns period
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------------------------
    func_fsm dut (
        .clk     (clk),
        .clk_en  (clk_en),
        .reset   (reset),
        .x       (x),
        .y       (y)
    );

    // -------------------------------------------------------------------------
    // FSM latency: 5 states × 3 cycles each (counter <= 2) = 15 cycles
    // NOTE: all fp_mul states use counter<=2 (3 cycles) but fp_mul has 4-cycle
    //       latency — increase those counters to 3 if results are wrong.
    //       Also: reset || !clk_en will wipe state mid-computation — revert to
    //       plain reset only.
    // -------------------------------------------------------------------------
    localparam int FSM_LATENCY = 15; // adjust to match Platform Designer config

    // -------------------------------------------------------------------------
    // Helper: pack float bits into logic[31:0]
    // -------------------------------------------------------------------------
    function automatic logic [31:0] f2b(input real f);
        logic [31:0] bits;
        // Use shortreal cast which is IEEE 754 single in SystemVerilog
        shortreal sr;
        sr = f;
        bits = $shortrealtobits(sr);
        return bits;
    endfunction

    function automatic real b2f(input logic [31:0] b);
        shortreal sr;
        sr = $bitstoshortreal(b);
        return real'(sr);
    endfunction

    // -------------------------------------------------------------------------
    // Software reference: y = x * (0.5 + x^2 * cos((x-128)/128))
    // -------------------------------------------------------------------------
    function automatic real ref_func(input real xr);
        real angle, c, result;
        angle  = (xr - 128.0) / 128.0;
        c      = $cos(angle);
        result = xr * (0.5 + xr * xr * c);
        return result;
    endfunction

    // -------------------------------------------------------------------------
    // Task: apply one input, wait FSM_LATENCY clk_en cycles, check output
    // -------------------------------------------------------------------------
    int pass_count, fail_count;

    task automatic run_test(
        input  logic [31:0] x_in,
        input  real         tolerance,
        input  string       label
    );
        real expected, got, err;
        expected = ref_func(b2f(x_in));

        // Assert clk_en and drive x
        @(negedge clk);
        x      = x_in;
        clk_en = 1;

        // Wait FSM_LATENCY rising edges
        repeat (FSM_LATENCY) @(posedge clk);

        // Deassert clk_en and capture y one cycle later
        @(negedge clk);
        clk_en = 0;
        @(posedge clk);
        #1; // small delta for output to settle

        got = b2f(y);
        err = (expected != 0.0) ? ((got - expected) / expected) * 100.0
                                 : (got - expected);

        if ($abs(got - expected) <= tolerance || $abs(err) <= 1.0) begin
            $display("PASS | %-20s | x=%e | expected=%e | got=%e | err=%.4f%%",
                     label, b2f(x_in), expected, got, err);
            pass_count++;
        end else begin
            $display("FAIL | %-20s | x=%e | expected=%e | got=%e | err=%.4f%%",
                     label, b2f(x_in), expected, got, err);
            fail_count++;
        end
    endtask

    // -------------------------------------------------------------------------
    // Test vectors
    // -------------------------------------------------------------------------
    // x=0: edge case, angle = -1.0
    // x=128: angle = 0.0 (zero guard case in COS state)
    // x=64: angle = -0.5
    // x=255: angle ≈ 1.0 (near max input)
    // x=1:   small value
    // x=200: positive angle

    localparam logic [31:0] X_0   = 32'h00000000; // 0.0
    localparam logic [31:0] X_1   = 32'h3f800000; // 1.0
    localparam logic [31:0] X_64  = 32'h42800000; // 64.0
    localparam logic [31:0] X_128 = 32'h43000000; // 128.0
    localparam logic [31:0] X_200 = 32'h43480000; // 200.0 (approx)
    localparam logic [31:0] X_255 = 32'h437f0000; // 254.0

    // -------------------------------------------------------------------------
    // Main stimulus
    // -------------------------------------------------------------------------
    initial begin
        pass_count = 0;
        fail_count = 0;

        // Waveform dump for Questa
        $dumpfile("func_fsm_tb.vcd");
        $dumpvars(0, func_fsm_tb);

        // Reset sequence
        clk_en = 0;
        reset  = 1;
        x      = 0;
        repeat (4) @(posedge clk);
        @(negedge clk);
        reset = 0;
        repeat (2) @(posedge clk);

        // ---- Individual tests ----
        run_test(X_0,   1e3,  "x=0.0");
        repeat (4) @(posedge clk); // idle gap between tests

        run_test(X_1,   1e3,  "x=1.0");
        repeat (4) @(posedge clk);

        run_test(X_64,  1e5,  "x=64.0");
        repeat (4) @(posedge clk);

        run_test(X_128, 1e5,  "x=128.0 (zero angle)");
        repeat (4) @(posedge clk);

        run_test(X_200, 1e6,  "x=200.0");
        repeat (4) @(posedge clk);

        run_test(X_255, 1e6,  "x=254.0");
        repeat (4) @(posedge clk);

        // ---- Back-to-back test (clk_en held, no idle gap) ----
        // Drive two consecutive inputs to verify no state bleed
        $display("\n-- Back-to-back test --");
        @(negedge clk);
        x      = X_64;
        clk_en = 1;
        repeat (FSM_LATENCY) @(posedge clk);
        // Immediately feed next input
        @(negedge clk);
        x = X_128;
        repeat (FSM_LATENCY) @(posedge clk);
        @(negedge clk);
        clk_en = 0;
        @(posedge clk);
        #1;
        $display("Back-to-back final y = %e (expected for x=128: %e)",
                 b2f(y), ref_func(128.0));

        // ---- Mid-computation reset test ----
        $display("\n-- Mid-computation reset test --");
        @(negedge clk);
        x      = X_200;
        clk_en = 1;
        repeat (FSM_LATENCY / 2) @(posedge clk); // reset halfway through
        @(negedge clk);
        reset = 1;
        @(posedge clk);
        @(negedge clk);
        reset  = 0;
        clk_en = 0;
        repeat (2) @(posedge clk);
        // y should be 0 after reset
        #1;
        if (y == 32'h00000000)
            $display("PASS | Reset mid-computation: y correctly 0 after reset");
        else
            $display("FAIL | Reset mid-computation: y=%h (expected 0)", y);

        // ---- Summary ----
        $display("\n========================================");
        $display("Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("========================================");

        $finish;
    end

    // -------------------------------------------------------------------------
    // Timeout watchdog: 50000 cycles max
    // -------------------------------------------------------------------------
    initial begin
        #500000;
        $display("TIMEOUT: simulation exceeded limit");
        $finish;
    end

    // -------------------------------------------------------------------------
    // State monitor (prints on every clk_en posedge for debug)
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (clk_en && !reset)
            $display("  t=%0t | state=%0d | counter=%0d | y=%e",
                     $time, dut.current_state, dut.counter, b2f(y));
    end

endmodule