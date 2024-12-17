// timer.v
module timer (
    input clk,
    input rst,
    input start,
    input timersw,
    input slow_enable,
    output reg [23:0] timer_count,
    output timer_digits [3:0]
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        timer_count <= 24'd0;
    end else if (start) begin
        timer_count <= 24'd0;
    end else if (timersw && slow_enable) begin
        timer_count <= timer_count + 1;
    end
end

// Extract digits from timer_count
assign timer_digits[0] = (timer_count % 10);
assign timer_digits[1] = (timer_count / 10) % 10;
assign timer_digits[2] = (timer_count / 100) % 10;
assign timer_digits[3] = (timer_count / 1000) % 10;

endmodule
