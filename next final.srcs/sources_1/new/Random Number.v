`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/11/26 19:34:51
// Design Name:
// Module Name: Random Number
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
// Game logic: If the `stop` button halts the random number at a value, pressing the correct keypad number
// lights the RGB LED green; pressing an incorrect number lights it red.
// LCD guides the user through steps and shows a timer that runs until a match.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

// Top module for Spartan-7 (XC7S75FGGA484-1)
module random_number_display (
input clk, // Clock input
input rst, // Reset input
input start, // Start button to begin generating random numbers
input stop, // Stop button to halt random number generation
input [7:0] keypad, // Keypad input for keys 1-8
output piezo, // Piezo output for sound tones
output [6:0] seg, // 7-segment display output
output [3:0] an, // Enable signal for 7-segment display
output [7:0] leds, // LED output to display the number
output reg [3:0] rgb_red, // RGB LED output (Green = 4'b0010, Red = 4'b1000)
output reg [3:0] rgb_green,
output reg [3:0] rgb_blue,
output [7:0] lcd_data, // LCD data pins
output lcd_rs, // LCD Register Select
output lcd_rw, // LCD Read/Write
output lcd_en // LCD Enable
);

reg [3:0] random_num; // Register to hold the random number (4 bits for 1-8)
reg generating; // Flag to indicate if random number generation is active
reg [23:0] timer_count; // Timer counter for elapsed time
wire [3:0] timer_digits [3:0]; // Digits to display on the LCD
wire match, not_match;

// LCD states and messaging
reg [127:0] lcd_message;
reg timersw;
reg [23:0] clk_divider; // Adjust bit width as per clk frequency
reg slow_clk;

reg slow_enable; // Enable signal for slow operations

always @(posedge clk or posedge rst) begin
if (rst) begin
clk_divider <= 24'd0;
slow_enable <= 1'b0;
end else begin
if (clk_divider == (1000 - 1)) begin // Assuming 100 MHz clock and 1 Hz timer
clk_divider <= 24'd0;
slow_enable <= 1'b1; // Generate one pulse every second
end else begin
clk_divider <= clk_divider + 1;
slow_enable <= 1'b0;
end
end
end
// Timer logic
always @(posedge clk or posedge rst) begin
if (rst) begin
timer_count <= 24'd0;
end else if (start) begin
timer_count <= 24'd0; // Reset timer on generate button press
end else if (timersw && slow_enable) begin
timer_count <= timer_count + 1; // Increment timer only on slow_enable
end
end

// Extract digits from timer_count
assign timer_digits[0] = (timer_count % 10);
assign timer_digits[1] = (timer_count / 10) % 10;
assign timer_digits[2] = (timer_count / 100) % 10;
assign timer_digits[3] = (timer_count / 1000) % 10;

// Random number generation logic
always @(posedge clk or posedge rst) begin
if (rst) begin
random_num <= 4'b0000;
end else if (generating) begin
random_num <= (random_num == 4'b1111) ? 4'b1000 : random_num + 1; // Cycle through 1 to 8
end
end

// Match logic
assign match = (keypad[random_num - 4'b1001]) ? 1'b1 : 1'b0;
assign not_match = (!keypad[random_num - 4'b1001] && |keypad) ? 1'b1 : 1'b0;
// Control logic for start, stop, and timersw
always @(posedge clk or posedge rst) begin
if (rst) begin
generating <= 1'b0;
timersw <= 1'b0;
end else if (start) begin
generating <= 1'b1;
timersw <= 1'b0; // Turn off timer when generation starts
end else if (stop) begin
generating <= 1'b0;
timersw <= 1'b1; // Start timer when stop is pressed
end else if (match) begin
timersw <= 1'b0; // Stop timer when a match occurs
end
end
reg [23:0] matched_time;
// Store the timer value when a match occurs
always @(posedge clk or posedge rst) begin
if (rst) begin
matched_time <= 24'd0;
end else if (match) begin
matched_time <= timer_count; // Capture the timer value at the match
end
end


// RGB LED control logic
always @(posedge clk or posedge rst) begin
if (rst) begin
rgb_blue <= 4'b0000;
rgb_red <= 4'b0000;
rgb_green <= 4'b0000;
end else if (match) begin
rgb_blue <= 4'b0000;
rgb_red <= 4'b0000;
rgb_green <= 4'b1111;
end else if (not_match) begin
rgb_blue <= 4'b0000;
rgb_red <= 4'b1111;
rgb_green <= 4'b0000;
end else begin
rgb_red <= 4'b0000;
rgb_blue <= 4'b1111;
rgb_green <= 4'b0000;
end
end

// Piezo control logic
reg [19:0] piezo_counter;
reg piezo_clk;
reg [13:0] tone_freq;

always @(posedge clk or posedge rst) begin
if (rst) begin
piezo_counter <= 20'd0;
piezo_clk <= 1'b0;
end else if (match || not_match) begin
if (piezo_counter >= tone_freq) begin
piezo_counter <= 20'd0;
piezo_clk <= ~piezo_clk;
end else begin
piezo_counter <= piezo_counter + 1;
end
end else begin
piezo_counter <= 20'd0;
piezo_clk <= 1'b0;
end
end

always @(*) begin
if (match) begin
tone_freq = 14'd50; // High tone for correct match
end else if (not_match) begin
tone_freq = 14'd100; // Low tone for incorrect match
end else begin
tone_freq = 14'd0; // No sound
end
end

assign piezo = piezo_clk;
// Register to store the matched time

// Store the timer value when a match occurs
always @(posedge clk or posedge rst) begin
if (rst) begin
matched_time <= 24'd0;
end else if (match) begin
matched_time <= timer_count; // Capture the timer value at the match
end
end

reg [7:0] ascii_digit [3:0]; // Array for storing ASCII digits of matched_time

always @(*) begin
// Extract each digit of matched_time
ascii_digit[0] = (matched_time % 10) + 8'd48; // Units place
ascii_digit[1] = ((matched_time / 10) % 10) + 8'd48; // Tens place
ascii_digit[2] = ((matched_time / 100) % 10) + 8'd48;// Hundreds place
ascii_digit[3] = ((matched_time / 1000) % 10) + 8'd48;// Thousands place
end

// Assign lcd_message based on game state
always @(posedge clk or posedge rst) begin
if (rst) begin
lcd_message <= " Press Generate";
end else if (start && !stop) begin
lcd_message <= " Press Stop";
end else if (timersw && !match) begin
lcd_message <= {" Timer:",
timer_digits[3] + 8'd48,
timer_digits[2] + 8'd48,
timer_digits[1] + 8'd48,
timer_digits[0] + 8'd48};
end else if (match) begin
lcd_message <= {" Time:",
ascii_digit[3],
ascii_digit[2],
ascii_digit[1],
ascii_digit[0]};
end
end

lcd_driver lcd (
.clk(clk),
.rst(rst),
.data_in(lcd_message),
.lcd_data(lcd_data),
.lcd_rs(lcd_rs),
.lcd_rw(lcd_rw),
.lcd_en(lcd_en)
);
// Assign LEDs to represent the random number
assign leds = (random_num == 4'b1001) ? 8'b00000001 :
(random_num == 4'b1010) ? 8'b00000011 :
(random_num == 4'b1011) ? 8'b00000111 :
(random_num == 4'b1100) ? 8'b00001111 :
(random_num == 4'b1101) ? 8'b00011111 :
(random_num == 4'b1110) ? 8'b00111111 :
(random_num == 4'b1111) ? 8'b01111111 :
(random_num == 4'b1000) ? 8'b11111111 :
8'b00000000; // For 8

// Instantiate 7-segment display driver
seven_segment_display ssd_inst (
.num(random_num),
.seg(seg),
.an() // "an" signal is hardwired in the driver module
);

endmodule

// 7-segment display driver
module seven_segment_display (
input [3:0] num,
output reg [6:0] seg,
output [3:0] an // Declare "an" as a constant output
);
assign an = 4'b1110; // Enable only one digit

always @(*) begin
case (num)
4'b1001: seg = 7'b0000110; // 1
4'b1010: seg = 7'b1011011; // 2
4'b1011: seg = 7'b1001111; // 3
4'b1100: seg = 7'b1100110; // 4
4'b1101: seg = 7'b1101101; // 5
4'b1110: seg = 7'b1111101; // 6
4'b1111: seg = 7'b0000111; // 7
4'b1000: seg = 7'b1111111; // 8
default: seg = 7'b0000000; // Blank
endcase
end
endmodule

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