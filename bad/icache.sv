module icache(
    input logic [5:0] pc,
    output logic [31:0] instruction
);

logic [31:0] instruction_memory [16];

// shift right by 2 
assign instruction = instruction_memory[pc >> 2];

endmodule