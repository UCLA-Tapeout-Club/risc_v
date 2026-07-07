module imem # (
    parameter IMEM_SIZE = 4
) (
    input logic clk,
    input logic rst_n,

    input logic [$clog2(IMEM_SIZE)-1:0] pc,
    output logic [7:0] insn,

    // SPI interface to load instructions
    input logic write_enable,
    input logic [$clog2(IMEM_SIZE)-1:0] waddr,
    input logic [7:0] wdata
);

logic [7:0] insn_memory [IMEM_SIZE];

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        insn_memory[0] <= 8'h00;
        insn_memory[1] <= 8'h00;
        insn_memory[2] <= 8'h00;
        insn_memory[3] <= 8'h00;
    end else if (write_enable) begin
        insn_memory[waddr] <= wdata;
    end
end

assign insn = insn_memory[pc];

endmodule
