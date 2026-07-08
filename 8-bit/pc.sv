module pc #(
    parameter IMEM_SIZE = 4
)(
    input logic clk,
    input logic rst_n,
    input logic cpu_enable,   // Enable PC to increment to run instructons
    output logic [$clog2(IMEM_SIZE)-1:0] pc_out
);

logic [$clog2(IMEM_SIZE)-1:0] pc;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc <= '0;
    end else if (cpu_enable) begin
        pc <= pc + 1'b1;
    end
end

assign pc_out = pc;

endmodule
