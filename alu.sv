module alu(
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    input logic [3:0] alu_op, // assume its this many for now, this is what online media tends to agree on. rs2 may be an immediate or a register value, but that's decided before we go here.
    output logic [31:0] alu_result,
    output logic is_zero
);

// add
// subtract
// xor
// or
// and 
// shift left logical
// shift right logical
// shift right arithmetic
// set less than
// set less than (U)

logic [31:0] add_result, sub_result, xor_result, or_result, and_result, sll_result, srl_result, sra_result, slt_result, sltu_result;

assign add_result = rs1 + rs2;
assign sub_result = rs1 - rs2;
assign xor_result = rs1 ^ rs2;
assign or_result = rs1 | rs2;
assign and_result = rs1 & rs2;
assign sll_result = rs1 << rs2;
assign srl_result = rs1 >> rs2;
assign sra_result = rs1 >>> rs2;
assign slt_result = (rs1 < rs2) ? 1 : 0;
assign sltu_result = (rs1 < rs2) ? 1 : 0;

always_comb begin
    case (alu_op)
        0:
            alu_result = add_result;
        1:
            alu_result = sub_result;
        2:
            alu_result = xor_result;
        3: 
            alu_result = or_result;
        4:
            alu_result = and_result;
        5: 
            alu_result = sll_result;
        6:
            alu_result = srl_result;
        7:
            alu_result = sra_result;
        8:
            alu_result = slt_result;
        9:
            alu_result = sltu_result;
    endcase
end



endmodule