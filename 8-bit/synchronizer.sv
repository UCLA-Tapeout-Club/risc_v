// 2-flip-flop synchronizer for asynchronous signals
// gives one full clock cycle to settle before the signal is used
// use for 1 bit signals
module synchronizer (
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic sync_out
);

logic sync_mid;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync_mid <= 1'b0;
        sync_out <= 1'b0;
    end else begin
        sync_mid <= async_in;
        sync_out <= sync_mid;
    end
end

endmodule
