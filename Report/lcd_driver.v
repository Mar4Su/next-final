module lcd_driver (
input clk, // Clock input
input rst, // Reset input
input [127:0] data_in, // 16 characters (128 bits) to display on the LCD
output reg [7:0] lcd_data, // LCD data pins
output reg lcd_rs, // LCD Register Select
output reg lcd_rw, // LCD Read/Write (set to 0 for write-only mode)
output reg lcd_en // LCD Enable
);

// State machine for LCD initialization and data writing
reg [3:0] state;
reg [7:0] current_char;
reg [3:0] char_index;

localparam IDLE = 4'd0,
INIT = 4'd1,
WRITE_CMD = 4'd2,
WRITE_CHAR = 4'd3,
NEXT_CHAR = 4'd4;

always @(posedge clk or posedge rst) begin
if (rst) begin
state <= INIT;
lcd_data <= 8'b00000000;
lcd_rs <= 1'b0;
lcd_rw <= 1'b0;
lcd_en <= 1'b0;
char_index <= 4'd0;
end else begin
case (state)
INIT: begin
// Initialization commands for the LCD
lcd_data <= 8'b00111000; // Function set: 8-bit, 2 lines, 5x8 dots
lcd_rs <= 1'b0;
lcd_en <= 1'b1;
state <= WRITE_CMD;
end

WRITE_CMD: begin
lcd_en <= 1'b0; // Finish command
state <= WRITE_CHAR;
end

WRITE_CHAR: begin
if (char_index < 16) begin
current_char <= data_in[(15 - char_index) * 8 +: 8]; // Extract character
lcd_data <= current_char; // Send character to LCD
lcd_rs <= 1'b1; // Data register
lcd_en <= 1'b1;
state <= NEXT_CHAR;
end else begin
state <= IDLE;
end
end

NEXT_CHAR: begin
lcd_en <= 1'b0; // Finish character write
char_index <= char_index + 1;
state <= WRITE_CHAR;
end

IDLE: begin
// Stay idle unless reset
end

default: state <= INIT;
endcase
end
end

endmodule