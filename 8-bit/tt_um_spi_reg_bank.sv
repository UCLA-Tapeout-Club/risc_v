/*
uio[0] - GPIO21 - CS
uio[1] - GPIO22 - MOSI
uio[2] - GPIO23 - MISO
uio[3] - GPIO24 - SCK
*/
module tt_um_spi_reg_bank (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs

    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

wire [7:0] current_dmem_value;
wire [1:0] pc_out;
wire cpu_done;
wire miso;

cpu_spi_top cpu_spi_top_i (
    .clk(clk),
    .rst_n(rst_n),
    .mosi(uio_in[1]),
    .sclk(uio_in[3]),
    .cs_n(uio_in[0]),
    .miso(miso),
    .current_dmem_value(current_dmem_value),
    .pc_out(pc_out),
    .cpu_done(cpu_done)
);

// Alt way to get the current dmem value and pc value out of the cpu for testing
assign uo_out = current_dmem_value;

// SPI interface (output)
assign uio_out[0] = 1'b0;
assign uio_out[1] = 1'b0;
assign uio_out[2] = miso;
assign uio_out[3] = 1'b0;

// Alt way to get pc value and cpu_done out of the cpu for testing
assign uio_out[4] = pc_out[0];
assign uio_out[5] = pc_out[1];
assign uio_out[6] = cpu_done;
assign uio_out[7] = 1'b0;

// Define Direction
assign uio_oe[0] = 1'b0; // CS input
assign uio_oe[1] = 1'b0; // MOSI input
assign uio_oe[2] = 1'b1; // MISO output
assign uio_oe[3] = 1'b0; // SCK input
assign uio_oe[4] = 1'b1; // debug PC[0]
assign uio_oe[5] = 1'b1; // debug PC[1]
assign uio_oe[6] = 1'b1; // debug cpu_done
assign uio_oe[7] = 1'b0;

// For verilator lint
wire _unused = &{ena, ui_in, uio_in[7:4], uio_in[2], 1'b0};

endmodule
