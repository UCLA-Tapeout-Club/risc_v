module imem (
    parameter IMEM_SIZE = 4
) (
    input logic [$clog2(IMEM_SIZE)-1:0] pc,
    output logic [7:0] insn
);

logic [7:0] insn_memory [IMEM_SIZE];
assign insn = insn_memory[pc];

endmodule