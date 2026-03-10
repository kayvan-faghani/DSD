`include "defs.sv"

module func_fsm(
    input logic         clk,
    input logic         clk_en,
    input logic         reset,
    input logic [31:0]  x,
    output logic [31:0] y
);
    
    typedef enum {SQUARE_SUBTRACT=0, COS, MUL_ONE, ADD, MUL_TWO} state;

    state current_state;
    state next_state;

    localparam logic [31:0] half = 32'h3f000000;
    localparam logic [31:0] angle_norm = 32'h43000000;
    
    logic [31:0] angle_sum;
    logic [31:0] x_squared;
    logic [31:0] cos;
    logic [31:0] rhs;
    logic [31:0] sum;
    logic [2:0] counter;

    logic [31:0] a_mul;
    logic [31:0] b_mul;
    logic en_mul;
    logic [31:0] result_mul;

    logic [31:0] a_add;
    logic [31:0] b_add;
    logic en_add;
    logic [31:0] result_add;

	logic [31:0] angle_in;
    logic [31:0] cos_out;

    always_comb begin
        a_add = 0;
        b_add = 0;
        en_add = 0;


        a_mul = 0;
        b_mul = 0;
        en_mul = 0;

        angle_in = 0;
        next_state = current_state;
        case (current_state)
            SQUARE_SUBTRACT: 
            begin
                a_add = x;
                b_add = {~(angle_norm[31]),angle_norm[30:0]};
                en_add = 1;

                a_mul = x;
                b_mul = x;
                en_mul = 1;
                if (counter == 0) next_state = COS;
            end
            COS:
            begin
                angle_in = (angle_sum == 0) ? 32'b0 : {angle_sum[31], angle_sum[30:23]-8'd7, angle_sum[22:0]};
                if (counter == 0) next_state = MUL_ONE;
            end
            MUL_ONE:
            begin
                a_mul = x_squared;
                b_mul = cos;
                en_mul = 1;
                if (counter == 0) next_state = ADD;
            end
            ADD:
            begin
                a_add = half;
                b_add = rhs;
                en_add = 1;
                if (counter == 0) next_state = MUL_TWO;
            end
            MUL_TWO: 
            begin
                a_mul = x;
                b_mul = sum;
                en_mul = 1;
                if (counter == 0) next_state = SQUARE_SUBTRACT;
            end
        endcase
    end
    
    always_ff @(posedge clk) begin
        if (reset || !clk_en) begin
            current_state <= SQUARE_SUBTRACT;
            counter <= 3;
            angle_sum <= 0;
            x_squared <= 0;
            cos <= 0;
            sum <= 0;
            rhs <= 0;
            y   <= 0;
        end
        else if (clk_en) begin
            current_state <= next_state;
            if (counter > 0) counter <= counter - 1;

            case (current_state)
                SQUARE_SUBTRACT: 
                begin
                    if (counter == 0) begin
                        counter <= 3;
                        angle_sum <= result_add;
                        x_squared <= result_mul;
                    end
                end
                COS:
                begin
                    if (counter == 0) begin
                        counter <= 3;
                        cos <= cos_out;
                    end
                end
                MUL_ONE:
                    if (counter == 0) begin
                        counter <= 3;
                        rhs <= result_mul;
                    end
                ADD:
                    if (counter == 0) begin
                        counter <= 3;
                        sum <= result_add;
                    end
                MUL_TWO: 
                    if (counter == 0) begin
                        counter <= 3;
                        y <= result_mul;
                    end
                default: 
                    counter <= 3;
            endcase
        end
    end

    cordic_top_reg cordic_top_reg (
        .clk(clk),
        .angle_in(angle_in),
        .cos_out(cos_out)
    );

    fp_add fp_add (
        .clk(clk),
        .areset(0),
        .a(a_add),
        .b(b_add),
        .en(en_add),
        .result(result_add)
    );

    fp_mul fp_mul (
        .clk(clk),
        .areset(0),
        .a(a_mul),
        .b(b_mul),
        .en(en_mul),
        .result(result_mul)
    );

endmodule