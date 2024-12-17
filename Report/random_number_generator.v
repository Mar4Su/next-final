// random_number_generator.v
module random_number_generator (
    input clk,
    input rst,
    input generating,
    output reg [3:0] random_num
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        random_num <= 4'b0000;
    end else if (generating) begin
        random_num <= (random_num == 4'b1111) ? 4'b1000 : random_num + 1;
    end
end

endmodule
