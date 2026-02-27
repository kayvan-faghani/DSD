module fp_mul
    (
        input clk,
        input areset,
        input [31:0]  a,
        input [31:0]  b,
		  input en,
        output [31:0]  result
    );

    fp_mul_final fp_mul_final
    (
        .clk(clk),
        .areset(areset),
        .a(a),
        .b(b),
		  .en(en),
        .q(result)
    );
		
endmodule // fp_mul
