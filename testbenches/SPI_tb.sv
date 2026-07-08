`timescale 1ns / 1ps
`include "alu_ops.svh"

/*
Think of this as a fake master module (RP2040) that sends commands to the SPI slave module.

This test checks:
1. SPI writes instructions into IMEM.
2. SPI control register starts the CPU.
3. CPU writes the expected result into DMEM.
*/

module SPI_tb;

logic clk;
logic rst_n;
logic mosi;
logic sclk;
logic cs_n;
logic miso;

logic [7:0] current_dmem_value;
logic [1:0] pc_out;
logic cpu_done;

localparam logic [7:0] ADD_X1_IMM2 = {1'b1, 2'd1, 2'd2, ADD};
localparam logic [7:0] WRITE_X1    = {1'b1, 2'd1, 2'd3, WRITE};

cpu_spi_top DUT (
    .clk(clk),
    .rst_n(rst_n),
    .mosi(mosi),
    .sclk(sclk),
    .cs_n(cs_n),
    .miso(miso),
    .current_dmem_value(current_dmem_value),
    .pc_out(pc_out),
    .cpu_done(cpu_done)
);

always #5 clk = ~clk;

task spi_send_byte(input logic [7:0] data);
    integer i;
    begin
        for (i = 7; i >= 0; i = i - 1) begin
            mosi = data[i];
            #20 sclk = 1'b1;
            #20 sclk = 1'b0;
        end
    end
endtask

task spi_write(input logic [7:0] command, input logic [7:0] data);
    begin
        cs_n = 1'b0;
        spi_send_byte(command);
        spi_send_byte(data);
        cs_n = 1'b1;
        mosi = 1'b0;
        #80;
    end
endtask

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    mosi = 1'b0;
    sclk = 1'b0;
    cs_n = 1'b1;

    #40;
    rst_n = 1'b1;
    #80;

    spi_write(8'h80, ADD_X1_IMM2);
    spi_write(8'h81, WRITE_X1);
    spi_write(8'h82, 8'h00);
    spi_write(8'h83, 8'h00);

    if (current_dmem_value != 8'h00) begin
        $fatal(1, "DMEM changed before CPU start. dmem=%0d", current_dmem_value);
    end

    spi_write(8'h84, 8'h01);

    wait (cpu_done);
    #20;

    if (current_dmem_value != 8'd3) begin
        $fatal(1, "SPI CPU flow failed. expected dmem=3 got dmem=%0d", current_dmem_value);
    end

    $display("PASS: SPI loaded instructions, cpu_start ran CPU, dmem result=%0d", current_dmem_value);
    $finish;
end

endmodule
