// match_checker.v
module match_checker (
    input [7:0] keypad,
    input [3:0] random_num,
    output match,
    output not_match
);

assign match = (keypad[random_num - 4'b1001]) ? 1'b1 : 1'b0;
assign not_match = (!keypad[random_num - 4'b1001] && |keypad) ? 1'b1 : 1'b0;

endmodule
