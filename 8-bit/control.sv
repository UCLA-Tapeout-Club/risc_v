#include "alu_ops.svh"

module control (
    input logic [7:0] insn,

    // control signals
    output alu_ops alu_ctrl,
    output logic opcode,
    output logic write,

    // register addresses
    output logic [1:0] rsd_addr,
    output logic [1:0] rs2_addr
);

assign opcode = insn[7];
assign alu_ctrl = insn[2:0];
assign write = (alu_ctrl == 3'b111) ? 1'b1 : 1'b0;
assign rsd_addr = insn[6:5];
assign rs2_addr = insn[4:3];

endmodule