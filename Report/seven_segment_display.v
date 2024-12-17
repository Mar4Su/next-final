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

