module fp_half(
    input  logic [31:0] x,
    output logic [31:0] x_plus_half
);
    wire        sign_x = x[31];
    wire [7:0]  exp_x  = x[30:23];
    wire [23:0] mant_x = (x[30:0] == 0) ? 24'b0 : {1'b1, x[22:0]};

    wire [7:0]  shift             = (exp_x >= 8'd126) ? exp_x - 8'd126 : 8'd126 - exp_x;
    wire [23:0] mant_x_aligned    = (exp_x >= 8'd126) ? mant_x               : (mant_x >> shift);
    wire [23:0] mant_half_aligned = (exp_x >= 8'd126) ? (24'h800000 >> shift) : 24'h800000;

    wire [24:0] sum = sign_x ?
                        (mant_x_aligned >= mant_half_aligned) ?
                        {1'b0, mant_x_aligned} - {1'b0, mant_half_aligned} :
                        {1'b0, mant_half_aligned} - {1'b0, mant_x_aligned} :
                        {1'b0, mant_x_aligned} + {1'b0, mant_half_aligned};

    wire sign_out = sign_x & (mant_x_aligned > mant_half_aligned);

    logic [4:0] lzc_count;
    always_comb begin
        lzc_count = 5'd24;
        for (int i = 24; i >= 0; i--) begin
            if (sum[i]) begin
                lzc_count = 5'd24 - i;
                break;
            end
        end
    end

    wire [24:0] mant_norm = {1'b0, sum[23:0]} << lzc_count;
    wire [7:0]  ref_exp   = (exp_x >= 8'd126) ? exp_x : 8'd126;
    wire [7:0]  exp_out   = (sum == 0) ? 8'd0 :
                             ref_exp - {3'b0, lzc_count} + 8'd1;
    wire [22:0] mant_out  = mant_norm[23:1];

    assign x_plus_half = {sign_out, exp_out, mant_out};

endmodule