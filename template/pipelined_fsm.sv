`include "defs.sv"

module pipelined_fsm(
    input logic         clk,
    input logic         clk_en,
    input logic         reset,
	 input  logic        valid_in,
    input logic [31:0]  x,
	 output logic  		valid,
    output logic [31:0] y
);
    
    logic [31:0] x_squared;
    logic [31:0] x_squared_delay [0:`CORDIC_STAGES-3];
    logic [31:0] x_delay [0:`CORDIC_STAGES+1];
	 
    logic [31:0] angle_in;
    logic [31:0] cos_out;
    logic [31:0] result_fp_mul_1;
    logic [31:0] result_fp_mul_1_plus_half;
    logic [31:0] result_fp_mul_2;
	 
	 localparam PIPE_DEPTH = `CORDIC_STAGES + 4;
    logic valid_sr [0:PIPE_DEPTH];
    always_ff @(posedge clk) begin
		  if (reset) begin
	        for (int i = 0; i < `CORDIC_STAGES-2; i++)
            x_squared_delay[i] <= 32'b0;
			  for (int i = 0; i < `CORDIC_STAGES+2; i++)
					x_delay[i] <= 32'b0;
			  for (int i = 0; i <= PIPE_DEPTH; i++)
               valid_sr[i] <= 1'b0;
		  end
        else if (clk_en) begin
            

					
            x_squared_delay[0] <= x_squared;
            x_delay[0] <= x;
				valid_sr[0] <= valid_in;
				
            for (int i = 1; i < `CORDIC_STAGES-2; i++)
                x_squared_delay[i] <= x_squared_delay[i-1]; 
            for (int i = 1; i < `CORDIC_STAGES+2; i++)
                x_delay[i] <= x_delay[i-1];
            for (int i = 1; i <= PIPE_DEPTH; i++)
                valid_sr[i] <= valid_sr[i-1];
        end
    end

    fp_angle fp_angle (
        .x(x),
        .angle(angle_in)
    );

    cordic_top cordic_top (
        .clk(clk),
        .clk_en(clk_en),
        .reset(reset),
        .angle_in(angle_in),
        .cos_out(cos_out)
    );


    // fp_add fp_add (
    //     .clk(clk),
    //     .areset(0),
    //     .a(a_add),
    //     .b(b_add),
    //     .en(en_add),
    //     .result(result_add)
    // );

	fp_mul fp_mul_squared (
		 .clk   (clk),
		 .areset(reset),
		 .a     (x),
		 .b     (x),
		 .en    (clk_en),
		 .result(x_squared)
	);
    fp_mul fp_mul_1 (
        .clk(clk),
        .areset(reset),
        .a(cos_out),
        .b(x_squared_delay[`CORDIC_STAGES-3]),
        .en(clk_en),
        .result(result_fp_mul_1)
    );

    fp_half fp_half (
        .x(result_fp_mul_1),
        .x_plus_half(result_fp_mul_1_plus_half)
    );

    fp_mul fp_mul_2 (
        .clk(clk),
        .areset(reset),
        .a(result_fp_mul_1_plus_half),
        .b(x_delay[`CORDIC_STAGES+1]),
        .en(clk_en),
        .result(result_fp_mul_2)
    );

	 assign valid = valid_sr[PIPE_DEPTH];
    assign y = result_fp_mul_2;
endmodule