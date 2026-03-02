`include "defs.sv"

module fixed_to_fl32(
    input   [`WORDLENGTH-1:0]   fixed,
    output  [31:0]              fl32
);
    
    logic [4:0] lzc_count;
    wire sign = fixed[`WORDLENGTH-1];
    wire [`WORDLENGTH-1:0] abs_fixed = sign ? (~fixed + 1'b1) : fixed;

    always_comb begin
        lzc_count = 5'd23;
        for (int i = `WORDLENGTH-1; i >= 0; i--) begin
            if (abs_fixed[i]) begin
                lzc_count = `WORDLENGTH-1 - i; 
                break;
            end
        end
    end

    wire [7:0] exp = (abs_fixed==0) ? 0 : 128-lzc_count;
    wire [22:0] mant = abs_fixed << (lzc_count+1) ;

    assign fl32 = {sign,exp,mant};

endmodule