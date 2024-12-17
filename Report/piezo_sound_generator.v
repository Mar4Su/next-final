// piezo_sound_generator.v
module piezo_sound_generator (
    input clk,
    input rst,
    input match,
    input not_match,
    output piezo
);

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
        tone_freq = 14'd50;  // High tone for correct match
    end else if (not_match) begin
        tone_freq = 14'd100; // Low tone for incorrect match
    end else begin
        tone_freq = 14'd0;   // No sound
    end
end

assign piezo = piezo_clk;

endmodule
