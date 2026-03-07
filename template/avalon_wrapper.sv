`include "defs.sv"

module avalon_wrapper (
    input  logic        clk,
    input  logic        reset,
    input  logic        ast_valid,
    input  logic [31:0] ast_data,
    input  logic        ast_startofpacket,
    input  logic        ast_endofpacket,
    output logic        ast_ready,
    input  logic [1:0]  avs_address,
    input  logic        avs_read,
    output logic [31:0] avs_readdata
);

    // Byte-swap to undo the endianness adapter
    logic [31:0] ast_data_swapped;
    assign ast_data_swapped = {ast_data[7:0], ast_data[15:8],
                                ast_data[23:16], ast_data[31:24]};

    // Registered inputs
    logic [31:0] ast_data_swapped_reg;   // ← declared
    logic        ast_endofpacket_reg;

	 logic 		  ast_valid_reg;
    assign ast_ready = 1'b1;

    // last is a one-cycle pulse — ast_endofpacket registered is sufficient
    logic clk_en, last, func_top_reset;
    assign last = ast_endofpacket_reg;

    logic [31:0] y, fx;
    logic        done;
    logic [31:0] last_word, last_fx;

    func_top func_top (
        .clk    (clk),
        .clk_en (clk_en),
        .reset  (func_top_reset),
        .last   (last),
		  .valid_in (ast_valid_reg),
        .x      (ast_data_swapped_reg),
        .y      (y),
        .fx_out (fx),
        .done   (done)
    );

    logic [31:0] y_final, word_count;
    logic        sticky_done;
	logic [5:0] drain_counter;
    always_ff @(posedge clk) begin
        if (reset) begin
            ast_data_swapped_reg <= 32'b0;
            ast_endofpacket_reg  <= 1'b0;
            y_final              <= 32'b0;
            sticky_done          <= 1'b0;
            clk_en               <= 1'b0;
            func_top_reset       <= 1'b1;
            word_count           <= 32'd0;
				drain_counter 		   <= 32'd0;
				ast_valid_reg 			<= 1'b0;
        end else begin
            // Always register the streaming inputs
            ast_data_swapped_reg <= ast_data_swapped;
            ast_endofpacket_reg  <= ast_endofpacket;  // clean one-cycle pulse
				ast_valid_reg 			<= ast_valid;
				
            if (ast_startofpacket) begin
                func_top_reset <= 1'b0;
                word_count     <= 32'd0;
                sticky_done    <= 1'b0;
                y_final        <= 32'b0;
            end

			  if (ast_valid) begin
					func_top_reset <= 1'b0;
					word_count     <= word_count + 1;
					drain_counter  <= `CORDIC_STAGES + 14;
					clk_en         <= 1'b1;
			  end else if (drain_counter > 0) begin
					
					drain_counter  <= drain_counter - 1;
					clk_en         <= 1'b1;
			  end else begin
					clk_en         <= 1'b0;
				end
				
				
            if (ast_endofpacket_reg) begin
                last_word <= ast_data_swapped_reg;
                last_fx   <= fx;
            end

            if (done) begin
                y_final     <= y;
                sticky_done <= 1'b1;
            end

            // Reading result clears state for next run
            if (avs_read && avs_address == 2'd1 && sticky_done) begin
                sticky_done    <= 1'b0;
                clk_en         <= 1'b0;
                func_top_reset <= 1'b1;
            end
        end
    end

    always_comb begin
        avs_readdata = 32'b0;
        if (avs_read) begin
            case (avs_address)
                2'd0: avs_readdata = {31'b0, sticky_done};
                2'd1: avs_readdata = y_final;
                2'd2: avs_readdata = last_fx;
                2'd3: avs_readdata = last_word;
                default: avs_readdata = 32'hDEADBEEF;
            endcase
        end
    end

endmodule