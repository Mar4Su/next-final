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
output [6:0] seg, // 7-segment display output
output [3:0] an, // Enable signal for 7-segment display
output [7:0] leds // LED output to display the number
);

reg [3:0] random_num; // Register to hold the random number (3 bits for 1-8)
reg generating; // Flag to indicate if random number generation is active

// Control logic for start and stop
always @(posedge clk or posedge rst) begin
if (rst)
generating <= 1'b0;
else if (start)
generating <= 1'b1;
else if (stop)
generating <= 1'b0;
end

// Random number generation logic
always @(posedge clk or posedge rst) begin
if (rst)
random_num <= 4'b0000;
else if (generating)
random_num <= (random_num == 4'b1111) ? 4'b1000 : random_num + 1; // Cycle through 1 to 8
end

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
