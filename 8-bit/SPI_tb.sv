/*
Think of this as a fake master module (RP2040) that sends commands to the SPI slave module
*/

task spi_send_byte(input logic [7:0] data);
    integer i;
    begin
        for (i = 7; i >= 0; i = i - 1) begin
            mosi = data[i];
            #5 sclk = 1'b1;
            #5 sclk = 1'b0;
        end
    end
endtask

cs_n = 1'b0;
spi_send_byte(8'h80);
spi_send_byte(8'hAA);
cs_n = 1'b1;

cs_n = 1'b0;
spi_send_byte(8'h81);
spi_send_byte(8'hBB);
cs_n = 1'b1;

cs_n = 1'b0;
spi_send_byte(8'h82);
spi_send_byte(8'hCC);
cs_n = 1'b1;

cs_n = 1'b0;
spi_send_byte(8'h83);
spi_send_byte(8'hDD);
cs_n = 1'b1;