module custom_cos_instr (
    input clk,
    input clk_en,
    input [31:0] dataa,   // Input: 10-bit Angle (0-1023 mapped to 0-2PI)
    output [31:0] result  // Output: 32-bit IEEE-754 Float
);

    wire [1:0] quadrant = dataa[9:8]; // Top 2 bits identify the quadrant
    wire [7:0] raw_angle = dataa[7:0]; // The 8-bit position within the quadrant
    
    reg [7:0] lut_addr;
    reg inv_sign;

    always @(*) begin
        case(quadrant)
            2'b00: begin lut_addr = raw_angle;        inv_sign = 0; end // Q1: 0 to PI/2
            2'b01: begin lut_addr = 8'hFF - raw_angle; inv_sign = 1; end // Q2: PI/2 to PI
            2'b10: begin lut_addr = raw_angle;        inv_sign = 1; end // Q3: PI to 3PI/2
            2'b11: begin lut_addr = 8'hFF - raw_angle; inv_sign = 0; end // Q4: 3PI/2 to 2PI
        endcase
    end

    reg [31:0] cos_rom [255:0];
    initial $readmemh("cos_lut.hex", cos_rom);

    reg [31:0] rom_data;
    reg out_sign;

    always @(posedge clk) begin
        if (clk_en) begin
            rom_data <= cos_rom[lut_addr];
            out_sign <= inv_sign; // Delay the sign to match ROM latency
        end
    end


    assign result = {rom_data[31] ^ out_sign, rom_data[30:0]};

endmodule