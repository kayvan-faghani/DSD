module fp_angle(
    input  logic [31:0] x,
    output logic [31:0] angle
);
    wire        sign_x = x[31];
    wire [7:0]  exp_x  = x[30:23];
    wire [23:0] mant_x = (x[30:0] == 0) ? 24'b0 : {1'b1, x[22:0]};

    wire [7:0]  shift            = (exp_x >= 8'd134) ? exp_x - 8'd134 : 8'd134 - exp_x;
    wire [23:0] mant_x_aligned   = (exp_x >= 8'd134) ? mant_x               : (mant_x >> shift);
    wire [23:0] mant_128_aligned = (exp_x >= 8'd134) ? (24'h800000 >> shift) : 24'h800000;

    wire [24:0] diff = sign_x ?
                        {1'b0, mant_x_aligned} + {1'b0, mant_128_aligned} :
                        (mant_x_aligned >= mant_128_aligned) ?
                        {1'b0, mant_x_aligned} - {1'b0, mant_128_aligned} :
                        {1'b0, mant_128_aligned} - {1'b0, mant_x_aligned};

    wire sign_diff = sign_x ? 1'b1 :
                    (mant_x_aligned >= mant_128_aligned) ? 1'b0 : 1'b1;

    logic [4:0] lzc_count;
    always_comb begin
        lzc_count = 5'd24;
        for (int i = 24; i >= 0; i--) begin
            if (diff[i]) begin
                lzc_count = 5'd24 - i;
                break;
            end
        end
    end

    wire [24:0] mant_norm   = {1'b0, diff[23:0]} << lzc_count;
    wire [7:0]  ref_exp     = (exp_x >= 8'd134) ? exp_x : 8'd134;
    wire [7:0]  exp_norm    = (diff == 0) ? 8'd0 :
                               ref_exp - {3'b0, lzc_count} + 8'd1;
    wire [22:0] mant_out    = mant_norm[23:1];
    wire [31:0] x_minus_128 = {sign_diff, exp_norm, mant_out};

    assign angle = (x_minus_128[30:0] == 0) ? 32'b0 :
                   {x_minus_128[31], x_minus_128[30:23] - 8'd7, x_minus_128[22:0]};

endmodule