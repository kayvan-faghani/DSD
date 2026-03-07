module avalon_wrapper(
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
    logic [31:0] y, y_final;
    logic        done;

    assign ast_ready = 1;
    assign clk_en    = ast_valid;
    assign last      = ast_valid && ast_endofpacket;

    func_top func_top (
        .clk    (clk),
        .clk_en (clk_en),
        .reset  (reset),
        .last   (last),
        .x      (ast_data),
        .y      (y),
        .done   (done)
    );

    always_ff @(posedge clk) begin
        if (reset)
            y_final <= 0;
        else if (done)
            y_final <= y;
    end

    always_comb begin
        avs_readdata = 0;
        case (avs_address)
            2'd0: avs_readdata = {31'b0, done};
            2'd1: avs_readdata = y_final;
        endcase
    end
endmodule