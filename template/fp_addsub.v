module fp_addsub
    (
        input clk,
        input areset,
        input [31:0]  a,
        input [31:0]  b,
		  input opSel,
		  input en,
        output [31:0]  result
    );

    fp_addsub_final fp_addsub_final
    (
        .clk(clk),
        .areset(areset),
        .a(a),
        .b(b),
		  .opSel(opSel),
		  .en(en),
        .q(result)
    );
		
endmodule // fp_add
