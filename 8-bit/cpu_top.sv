`include "alu_ops.svh"
/*
CPU only runs when cpu_enable is high. This is controlled by the run_controller module.
Technically only imem is writeable when cpu_enable is low, but the CPU will not run unless cpu_enable is high.
*/
module cpu_top(
    input logic clk,
    input logic rst_n,
    input logic cpu_start, //use for modules that store state
    input logic cpu_step,
    input logic imem_write_enable,
    input logic [1:0] imem_waddr,
    input logic [7:0] imem_wdata,
    output logic [7:0] current_dmem_value,
    output logic [1:0] pc_out,
    output logic cpu_done
);

logic cpu_enable;
run_controller cpu_run_controller (
    .clk(clk),
    .rst_n(rst_n),
    .cpu_start(cpu_start),
    .cpu_step(cpu_step),
    .pc_value(pc_out),
    .cpu_enable(cpu_enable),
    .cpu_done(cpu_done)
);

pc program_counter (
    .clk(clk),
    .rst_n(rst_n),
    .cpu_enable(cpu_enable),
    .pc_out(pc_out)
);

logic [7:0] insn;
imem instruction_memory (
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc_out),
    .insn(insn),
    .write_enable(imem_write_enable),
    .waddr(imem_waddr),
    .wdata(imem_wdata)
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
    .cpu_enable(cpu_enable),

    .rsd_addr(rsd_addr),
    .rs2_addr(rs2_addr),

    .write_data(write_data),
    .rsd_data(rsd_data),
    .rs2_data(rs2_data)
);

logic [7:0] b;
assign b = (opcode == 1) ? {6'b000000, rs2_addr} : rs2_data;
alu ALU (
    .a(rsd_data),
    .b(b),
    .operation(alu_ctrl),

    .result(write_data)
);

dmem data_memory (
    .clk(clk),
    .rst_n(rst_n),

    .write(write && cpu_enable),
    .alu_out(write_data),
    .current_dmem_value(current_dmem_value)
);

endmodule
