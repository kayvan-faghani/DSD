`include "defs.sv"
module func_top(
    input  logic        clk,
    input  logic        clk_en,
    input  logic        reset,
    input  logic        last, 
	 input  logic 			valid_in,
    input  logic [31:0] x,
    output logic [31:0] y,
	 output logic [31:0] fx_out,
    output logic        done
);
    logic [31:0] fx;
     logic pipeline_valid;

    pipelined_fsm pipelined_fsm (
        .clk(clk),
        .clk_en(clk_en),
        .reset(reset),
		  .valid_in(valid_in),
        .x(x),
        .valid(pipeline_valid),
        .y(fx)
    );
    typedef enum {CALCULATING=0,FINISHED_RECEIVING} state;
    state current_state, next_state;
     logic [31:0] acc_1, acc_2, acc_3;
    logic [31:0] result_acc_1, result_acc_2, result_acc_3;
    logic [1:0] acc_sel;
    logic [5:0] counter;
     logic [31:0] result_add_1, result_final;
    logic [31:0] final_acc_1, final_acc_2, final_acc_3;
     logic [1:0] acc_sel_d1, acc_sel_d2;
    logic        wb_valid [0:1];  // 2-deep = fp_add latency
		logic [1:0]  wb_sel   [0:1];
	 assign next_state = (last || current_state == FINISHED_RECEIVING) ? FINISHED_RECEIVING : CALCULATING;
    always_ff @(posedge clk) begin
        if (reset) begin
            acc_1 <= 32'b0;
            acc_2 <= 32'b0;
            acc_3 <= 32'b0;
            final_acc_1 <= 32'b0;
            final_acc_2 <= 32'b0;
            final_acc_3 <= 32'b0;
            acc_sel <= 2'd0;
            done <= 1'b0;
            counter <= `CORDIC_STAGES + 13;
				wb_valid[0] <= 0; wb_valid[1] <= 0;
				wb_sel[0]   <= 0; wb_sel[1]   <= 0;
				y <= 32'b0;
            current_state <= CALCULATING;
        end
        else if (clk_en) begin
            current_state <= next_state;
                if (pipeline_valid) begin
                  acc_sel    <= (acc_sel == 2'd2) ? 2'd0 : acc_sel + 1;
                  acc_sel_d1 <= acc_sel;
                  acc_sel_d2 <= acc_sel_d1;
					end 
					  wb_valid[0] <= pipeline_valid;
					  wb_valid[1] <= wb_valid[0];
					  wb_sel[0]   <= acc_sel;
					  wb_sel[1]   <= wb_sel[0];
                 if (wb_valid[1]) begin
							case (wb_sel[1])
								 2'd0: acc_1 <= result_acc_1;
								 2'd1: acc_2 <= result_acc_2;
								 2'd2: acc_3 <= result_acc_3;
								 default: ;
							endcase
					  end
            // if (next_state == FINISHED_RECEIVING && current_state == CALCULATING) begin
                // final_acc_1 <= result_add_1;
                // final_acc_2 <= result_add_2;
            // end
            if (current_state == FINISHED_RECEIVING) begin
                if (counter > 0 )
                    counter <= counter - 1;
                if (counter == 5)
                begin
                    final_acc_1 <= result_acc_1;
                    final_acc_2 <= result_acc_2;
                    final_acc_3 <= result_acc_3;
                end
                if (counter == 0) begin
                    done <= 1'b1;
						  y <= result_final;
					 end
            end

        end
    end
    fp_add fp_acc_1 (
        .clk   (clk),
        .areset(reset),
        .a     ((acc_sel == 2'd0 && pipeline_valid && clk_en) ? fx : 32'b0),
        .b     (acc_1),
        .en    (clk_en),
        .result(result_acc_1)
    );
    fp_add fp_acc_2 (
        .clk   (clk),
        .areset(reset),
        .a     ((acc_sel == 2'd1 && pipeline_valid && clk_en) ? fx : 32'b0),
        .b     (acc_2),
        .en    (clk_en),
        .result(result_acc_2)
    );
    fp_add fp_acc_3 (
        .clk   (clk),
        .areset(reset),
        .a     ((acc_sel == 2'd2 && pipeline_valid && clk_en) ? fx : 32'b0),
        .b     (acc_3),
        .en    (clk_en),
        .result(result_acc_3)
    );

     fp_add fp_add_1 (
        .clk   (clk),
        .areset(reset),
        .a     (final_acc_1),
        .b     (final_acc_2),
        .en    (clk_en),
        .result(result_add_1)
    );
    fp_add fp_add_2 (
        .clk   (clk),
        .areset(reset),
        .a     (result_add_1),
        .b     (final_acc_3),
        .en    (clk_en),
        .result(result_final)
    );
	 assign fx_out = fx; 
endmodule