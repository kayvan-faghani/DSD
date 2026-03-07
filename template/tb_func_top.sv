`timescale 1ns/1ps
`include "defs.sv"

module tb_func_top;

    logic        clk;
    logic        clk_en;
    logic        reset;
    logic        last;
    logic [31:0] x;
    logic [31:0] y;
    logic        done;

    initial clk = 0;
    always #5 clk = ~clk;

    func_top dut (
        .clk    (clk),
        .clk_en (clk_en),
        .reset  (reset),
        .last   (last),
        .x      (x),
        .y      (y),
        .done   (done)
    );

    // -------------------------------------------------------------------------
    // Float helpers
    // -------------------------------------------------------------------------
    function automatic logic [31:0] f2b(input shortreal f);
        return $shortrealtobits(f);
    endfunction

    function automatic shortreal b2f(input logic [31:0] b);
        return $bitstoshortreal(b);
    endfunction

    function automatic real ref_f(input real xr);
        return xr * (0.5 + xr*xr*$cos((xr-128.0)/128.0));
    endfunction

    // -------------------------------------------------------------------------
    // Max vector size
    // -------------------------------------------------------------------------
    localparam int MAXN = 64;

    logic [31:0] vec   [0:MAXN-1];
    real         xreal [0:MAXN-1];
    int          pass_count, fail_count;

    // -------------------------------------------------------------------------
    // Task: run one vector test
    // -------------------------------------------------------------------------
    task automatic run_vector(
        input int    n,
        input real   tolerance,
        input string label
    );
        real expected, got, err;
        int i;

        // Compute reference sum
        expected = 0.0;
        for (i = 0; i < n; i++)
            expected += ref_f(xreal[i]);

        // Reset DUT
        @(negedge clk);
        reset  = 1;
        clk_en = 0;
        last   = 0;
        x      = 32'b0;
        repeat (4) @(posedge clk);

        // Deassert reset and immediately drive first element
        @(negedge clk);
        reset  = 0;
        clk_en = 1;
        x      = vec[0];
        last   = (n == 1) ? 1'b1 : 1'b0;

        // Feed remaining inputs one per cycle
        for (i = 1; i < n; i++) begin
            @(negedge clk);
            x    = vec[i];
            last = (i == n-1) ? 1'b1 : 1'b0;
        end
        @(negedge clk);
        last = 0;

        // Wait for done with timeout
        begin
            int timeout;
            timeout = 0;
            while (!done && timeout < 100000) begin
                @(posedge clk);
                timeout++;
            end
            if (timeout >= 100000) begin
                $display("TIMEOUT | %-25s", label);
                fail_count++;
                return;
            end
        end

        @(posedge clk);
        #1;
        got = real'(b2f(y));

        // Deassert clk_en between tests
        @(negedge clk);
        clk_en = 0;
        repeat (4) @(posedge clk);

        err = (expected != 0.0) ? ((got - expected) / expected) * 100.0
                                 : got - expected;

        if ($abs(err) < tolerance) begin
            $display("PASS | %-25s | expected=%e | got=%e | err=%.4f%%",
                     label, expected, got, err);
            pass_count++;
        end else begin
            $display("FAIL | %-25s | expected=%e | got=%e | err=%.4f%%",
                     label, expected, got, err);
            fail_count++;
        end
    endtask

    // -------------------------------------------------------------------------
    // Main stimulus
    // -------------------------------------------------------------------------
    integer i;
    initial begin
        pass_count = 0;
        fail_count = 0;
        clk_en = 0;
        reset  = 1;
        last   = 0;
        x      = 0;

        $dumpfile("tb_func_top.vcd");
        $dumpvars(0, tb_func_top);

        repeat (4) @(posedge clk);

        $display("\n========================================");
        $display("func_top testbench");
        $display("========================================");

        // ---- C Small: N=52, step=5.0 ----
        xreal[0] = 0.0;
        vec[0]   = f2b(0.0);
        for (i = 1; i < 52; i++) begin
            xreal[i] = xreal[i-1] + 5.0;
            vec[i]   = f2b(shortreal'(xreal[i]));
        end
        run_vector(52, 2.0, "C Small (N=52, step=5.0)");

        // ---- Medium: N=32, step=8 ----
        for (i = 0; i < 32; i++) begin
            xreal[i] = real'(i * 8);
            vec[i]   = f2b(shortreal'(i * 8));
        end
        run_vector(32, 2.0, "Medium (N=32, step=8)");

        // ---- Large: N=64, step=4 ----
        for (i = 0; i < 64; i++) begin
            xreal[i] = real'(i * 4);
            vec[i]   = f2b(shortreal'(i * 4));
        end
        run_vector(64, 2.0, "Large  (N=64, step=4)");

        // ---- Single element: x=128 ----
        xreal[0] = 128.0;
        vec[0]   = f2b(128.0);
        run_vector(1, 2.0, "Single x=128.0");

        // ---- Single element: x=0 ----
        xreal[0] = 0.0;
        vec[0]   = f2b(0.0);
        run_vector(1, 2.0, "Single x=0.0");

        $display("\n========================================");
        $display("Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("========================================");

        $finish;
    end

    // Timeout watchdog
    initial begin
        #100000000;
        $display("GLOBAL TIMEOUT");
        $finish;
    end

    // Done monitor
    always @(posedge done)
        $display("  t=%0t | done asserted | y=%e", $time, real'(b2f(y)));

endmodule