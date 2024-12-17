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

// main_module.v
module random_number_display (
    input clk,
    input rst,
    input start,
    input stop,
    input [7:0] keypad,
    output piezo,
    output [6:0] seg,
    output [3:0] an,
    output [7:0] leds,
    output reg [3:0] rgb_red,
    output reg [3:0] rgb_green,
    output reg [3:0] rgb_blue,
    output [7:0] lcd_data,
    output lcd_rs,
    output lcd_rw,
    output lcd_en
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


rgb_led_controller u_rgb (
    .clk(clk),
    .rst(rst),
    .match(match),
    .not_match(not_match),
    .rgb_red(rgb_red),
    .rgb_green(rgb_green),
    .rgb_blue(rgb_blue)
);

random_number_generator u_random (
    .clk(clk),
    .rst(rst),
    .generating(generating),
    .random_num(random_num)
);

piezo_sound_generator u_piezo (
    .clk(clk),
    .rst(rst),
    .match(match),
    .not_match(not_match),
    .piezo(piezo)
);

match_checker u_match (
    .keypad(keypad),
    .random_num(random_num),
    .match(match),
    .not_match(not_match)
);

seven_segment_display u_ssd (
    .num(random_num),
    .seg(seg),
    .an(an)
);

lcd_driver u_lcd (
    .clk(clk),
    .rst(rst),
    .data_in(lcd_message),
    .lcd_data(lcd_data),
    .lcd_rs(lcd_rs),
    .lcd_rw(lcd_rw),
    .lcd_en(lcd_en)
);

assign leds = (random_num == 4'b1001) ? 8'b00000001 : // other cases
                8'b00000000;

endmodule
