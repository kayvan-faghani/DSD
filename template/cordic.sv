`include "defs.sv"

module cordic(
    input                       clk,
    input                       clk_en,
    input                       reset,
    input   [`WORDLENGTH-1:0]   angle_in,
    output  [`WORDLENGTH-1:0]   cos_out
);

    localparam logic [`WORDLENGTH-1:0] atans [0:`CORDIC_STAGES-1] = '{
    23'h1921fb, 23'h0ed634, 23'h07D6DD, 23'h03FAB7, 
	 23'h01FF56, 23'h00FFEB, 23'h007FFD, 23'h004000, 
	 23'h002000, 23'h001000, 23'h000800, 23'h000400, 
	 23'h000200, 23'h000100, 23'h000080, 23'h000040, 
	 23'h000020
	 };
	 
	 localparam logic [`WORDLENGTH-1:0] k_inv = 23'h136e9e;
	 
    logic signed [`CORDIC_STAGES:0] [`WORDLENGTH-1:0] x_array;
    logic signed [`CORDIC_STAGES:0] [`WORDLENGTH-1:0] y_array;
    logic signed [`CORDIC_STAGES:0] [`WORDLENGTH-1:0] z_array;
    
    assign x_array[0] = k_inv;
    assign y_array[0] = 0;
    assign z_array[0] = angle_in;
    genvar i;
    generate
        for (i=0; i < `CORDIC_STAGES; i++) begin : cordic_step
            wire z_sign = z_array[i][`WORDLENGTH-1];
            wire signed [`WORDLENGTH-1:0] shift_x = $signed(x_array[i]) >>> i;
            wire signed [`WORDLENGTH-1:0] shift_y = $signed(y_array[i]) >>> i;
            wire signed [`WORDLENGTH-1:0] x_next = z_sign 	    ?	 
                                    x_array[i] + shift_y		: 
                                    x_array[i] - shift_y 	    ;
            
            wire signed [`WORDLENGTH-1:0] y_next = z_sign 	    ?
                                    y_array[i] - shift_x 	    :
                                    y_array[i] + shift_x		;
            
            wire signed [`WORDLENGTH-1:0] z_next = z_sign 	    ?
                                    z_array[i] + atans[i] 	    :
                                    z_array[i] - atans[i]	    ;
												
				 always_ff @(posedge clk) begin
					 if (reset)
					 begin
						  x_array[i+1] <= 0;
						  y_array[i+1] <= 0;
						  z_array[i+1] <= 0;
					 end
                else if (clk_en)
                begin
                    x_array[i+1] <= x_next;
						  y_array[i+1] <= y_next;
						  z_array[i+1] <= z_next;
                end
				end
            
        end
    endgenerate
	 
    assign cos_out = x_array[`CORDIC_STAGES];

endmodule