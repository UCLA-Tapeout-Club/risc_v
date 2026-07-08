module cpu_spi_top (
    input logic clk,
    input logic rst_n,

    input logic mosi,
    input logic sclk,
    input logic cs_n,
    output logic miso,

    output logic [7:0] current_dmem_value,
    output logic [1:0] pc_out,
    output logic cpu_done
);

logic imem_write_enable;
logic [1:0] imem_waddr;
logic [7:0] imem_wdata;
logic cpu_start;
logic cpu_step;

spi_slave spi_interface (
    .clk(clk),
    .rst_n(rst_n),
    .mosi(mosi),
    .sclk(sclk),
    .cs_n(cs_n),
    .miso(miso),
    .write_enable(imem_write_enable),
    .imem_waddr(imem_waddr),
    .imem_wdata(imem_wdata),
    .cpu_start(cpu_start),
    .cpu_step(cpu_step),
    .dmem_value(current_dmem_value),
    .pc_value(pc_out)
);

cpu_top cpu_core (
    .clk(clk),
    .rst_n(rst_n),
    .cpu_start(cpu_start),
    .cpu_step(cpu_step),
    .imem_write_enable(imem_write_enable),
    .imem_waddr(imem_waddr),
    .imem_wdata(imem_wdata),
    .current_dmem_value(current_dmem_value),
    .pc_out(pc_out),
    .cpu_done(cpu_done)
);

endmodule
