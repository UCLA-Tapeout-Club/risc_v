/*
Input -> Instruction Data [7:0]      (mosi)
Output -> Current DMEM value [7:0]   (miso)

SPI parallel stream interface 
Inputs needed (connects to the imem): 
[1:0] -> instruction mem for 4 slots
[7:0] -> instruction size
write enable -> write to instruction memory

SPI transaction 1: write IMEM/input data
SPI transaction 2: write start register
processor runs internally
SPI transaction 3: read status register
SPI transaction 4: read DMEM output

MAC python script 
-> RP2040 (receive command and send SPI bytes) 
-> SPI module (receive bytes packet and write to IMEM) 
-> CPU (run program) 
-> SPI module (read DMEM output) 
-> RP2040 (send output to MAC python script)

Packet information: 
16-bit packet:
[15:12] command
[11:8] address
[7:0] instruction data
*/
module SPI (
    input logic rst_n,
    // SPI interface
    input logic mosi,
    input logic sclk,
    input logic cs_n, // Slave select (active low)
    output logic miso, 

    output logic write_enable,  // write enable for instruction memory
    output logic [1:0] imem_waddr, // which instruction slot to write to 0-3
    output logic [7:0] imem_wdata, // instruction data to write to IMEM

    output logic cpu_start,  // start CPU execution
    output logic cpu_step,   // step CPU execution

    input  logic [7:0] dmem_value,   // current DMEM value (result)
    input  logic [1:0] pc_value      // current PC value
);
endmodule



// load -> step CPU -> read reg/PC -> mem inspect