// rgb_led_controller.v
module rgb_led_controller (
    input clk,
    input rst,
    input match,
    input not_match,
    output reg [3:0] rgb_red,
    output reg [3:0] rgb_green,
    output reg [3:0] rgb_blue
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rgb_blue <= 4'b0000;
        rgb_red <= 4'b0000;
        rgb_green <= 4'b0000;
    end else if (match) begin
        rgb_blue <= 4'b0000;
        rgb_red <= 4'b0000;
        rgb_green <= 4'b1111; // Green for match
    end else if (not_match) begin
        rgb_blue <= 4'b0000;
        rgb_red <= 4'b1111;  // Red for mismatch
        rgb_green <= 4'b0000;
    end else begin
        rgb_red <= 4'b0000;
        rgb_blue <= 4'b1111; // Blue during number generation
        rgb_green <= 4'b0000;
    end
end

endmodule
