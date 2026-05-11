// the program counter should take in a clock signal, the previous/current program counter, and reset when necessary

module pc (
    input logic clock,
    input logic [5:0] next_pc,
    input logic reset_n,
    output logic [5:0] out_pc
);

logic [5:0] current_pc; // 2^6 instructions

// we assume we do pc = pc + 4

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset) begin
        current_pc <= 6'b0; // reset program counter
    end else begin
        current_pc <= next_pc; // take on next program counter
    end
end

assign out_pc = current_pc;

endmodule