`include "alu_ops.svh"

module alu (
    input logic [7:0] a,
    input logic [7:0] b,
    input alu_ops operation,

    output logic [7:0] result
);

always_comb begin
    result = a;
    case (operation)
        ADD: result = a + b;
        SUB: result = a - b;
        RIGHT_SHIFT: result = a >> b[4:0];
        LEFT_SHIFT: result = a << b[4:0];
        AND: result = a & b;
        OR: result = a | b;
        XOR: result = a ^ b;
    endcase
end

endmodule