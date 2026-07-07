`include "alu_ops.svh"

module top(
    input logic clk,
    input logic rst_n,
    output logic [7:0] current_dmem_value
);

logic [1:0] pc_out;
pc_module program_counter (
    .clk(clk),
    .rst_n(rst_n),
    .pc_out(pc_out)
);

logic [7:0] insn;
imem instruction_memory (
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc_out),
    .insn(insn),
    .write_enable(1'b0),
    .waddr('0),
    .wdata('0)
);

alu_ops alu_ctrl;
logic opcode;
logic write;

logic [1:0] rsd_addr;
logic [1:0] rs2_addr;

control control_unit (
    .insn(insn),
    .alu_ctrl(alu_ctrl),
    .opcode(opcode),
    .write(write),
    .rsd_addr(rsd_addr),
    .rs2_addr(rs2_addr)
);

logic [7:0] write_data;
logic [7:0] rsd_data;
logic [7:0] rs2_data;
rf register_file (
    .clk(clk),
    .rst_n(rst_n),

    .rsd_addr(rsd_addr),
    .rs2_addr(rs2_addr),

    .write_data(write_data),
    .rsd_data(rsd_data),
    .rs2_data(rs2_data)
);

logic [7:0] b;
assign b = (opcode == 1) ? rs2_addr : rs2_data;
alu ALU (
    .a(rsd_data),
    .b(b),
    .operation(alu_ctrl),

    .result(write_data)
);

dmem data_memory (
    .clk(clk),
    .rst_n(rst_n),

    .write(write),
    .alu_out(write_data),
    .current_dmem_value(current_dmem_value)
);

endmodule
