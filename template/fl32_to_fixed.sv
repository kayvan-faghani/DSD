`include "defs.sv"

module fl32_to_fixed(
    input   [31:0]              fl32,
    output  [`WORDLENGTH-1:0]   fixed
);
    wire sign = fl32[31];
    wire [7:0] exp = fl32[30:23];
    wire [22:0] mant = fl32[22:0];
    wire [23:0] full_mant = {1'b1, mant};

	int shift_val;
    assign shift_val = 127 + 2 - exp;

	logic [`WORDLENGTH-1:0] abs_fixed;
    assign abs_fixed = (shift_val >= 0) ? (full_mant >> shift_val) : (full_mant << (-shift_val));

    assign fixed = sign ? (~abs_fixed + 1'b1) : abs_fixed;

endmodule