module fp_add
    (
        input clk,
        input areset,
        input [31:0]  a,
        input [31:0]  b,
		input en,
        output [31:0]  result
    );

    fp_add_final fp_add_final
    (
        .clk(clk),
        .areset(areset),
        .a(a),
        .b(b),
		.en(en),
        .q(result)
    );
		
endmodule // fp_add
