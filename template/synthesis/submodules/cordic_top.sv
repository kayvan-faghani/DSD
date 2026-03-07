`include "defs.sv"

module cordic_top(
    input           clk,
    input           clk_en,
    input   [31:0]  angle_in,
    output  [31:0]  cos_out
);
    logic [`WORDLENGTH-1:0] fixed_angle_in;
    logic [`WORDLENGTH-1:0] fixed_cos_out;

    fl32_to_fixed fl32_to_fixed_inst(
        .fl32(angle_in),
        .fixed(fixed_angle_in)
    );

    cordic cordic_inst(
        .clk(clk),
        .clk_en(clk_en),
        .angle_in(fixed_angle_in),
        .cos_out(fixed_cos_out)
    );

    fixed_to_fl32 fixed_to_f32_inst(
        .fixed(fixed_cos_out),
        .fl32(cos_out)
    );
    

endmodule