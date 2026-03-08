module fp_mul_real
    (
        input clk,
        input areset,
        input [31:0]  a,
        input [31:0]  b,
		  input en,
        output [31:0]  result
    );

    fp_mul_actual fp_mul_actual
    (
        .clk(clk),
        .areset(areset),
        .a(a),
        .b(b),
		  .en(en),
        .q(result)
    );
		
endmodule // fp_mul
