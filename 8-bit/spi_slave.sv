/*
THIS IS THE SPI SLAVE MODULE FOR THE 8-BIT CPU PROJECT

Input -> Instruction Data [7:0]      (mosi)
Output -> Current DMEM value [7:0]   (miso)

SPI mode 0: CPOL=0, CPHA=0

MAC python script
-> RP2040 (receive command and send SPI bytes)
-> SPI module (receive bytes packet and write to IMEM)
-> CPU (run program)
-> SPI module (read DMEM output)
-> RP2040 (send output to MAC python script)

Packet format:
byte 1 is the command/address byte
byte 2 is the data byte (if applicable)
Example commands:
    0x80 0xAA (write instruction 0xAA to IMEM[0])
        first byte  = 0x80 = write to address 0
        second byte = 0xAA = instruction data
    0x05 0x00 (read DMEM value)
        first byte  = 0x05 = read address 5, which is DMEM result
        second byte = 0x00 = dummy byte, used to give SPI clocks while MISO sends data back

[7] [6:3] [2:0]
 W  unused addr

 0x80 = 1000_0000
       ^    ^^^
       |     |
       |     address = 0
       write = 1


Supported commands:
0x80 data -> write imem[0] = data
0x81 data -> write imem[1] = data
0x82 data -> write imem[2] = data
0x83 data -> write imem[3] = data
0x84 data -> control register: data[0] = cpu_start, data[1] = cpu_step
0x05 0x00 -> read dmem_value on miso
0x06 0x00 -> read pc_value on miso

SPI parallel stream interface
Inputs needed (connects to the imem):
[1:0] -> instruction mem for 4 slots
[7:0] -> instruction size
write enable -> write to instruction memory

*/

module spi_slave (
    input logic clk,
    input logic rst_n,

    // SPI pin interface
    input logic mosi,
    input logic sclk,
    input logic cs_n, // Slave select (active low)
    output logic miso,

    // Instruction memory interface
    output logic write_enable,       
    output logic [1:0] imem_waddr,   // which instruction slot to write to: 0-3
    output logic [7:0] imem_wdata,   // instruction data to write to IMEM

    // CPU control interface
    output logic cpu_start,          // to start CPU execution
    output logic cpu_step,           // to step CPU execution

    // CPU debug/readback values
    input logic [7:0] dmem_value,   // current DMEM value/result
    input logic [1:0] pc_value      // current PC value
);

localparam logic [2:0] ADDR_IMEM0   = 3'd0;
localparam logic [2:0] ADDR_IMEM1   = 3'd1;
localparam logic [2:0] ADDR_IMEM2   = 3'd2;
localparam logic [2:0] ADDR_IMEM3   = 3'd3;
localparam logic [2:0] ADDR_CONTROL = 3'd4;
localparam logic [2:0] ADDR_DMEM    = 3'd5;
localparam logic [2:0] ADDR_PC      = 3'd6;

typedef enum logic [1:0] {
    WAIT_COMMAND,
    WAIT_WRITE_DATA,
    SHIFT_READ_DATA   //NEED TO SHIFT OUT DATA ON MISO
} spi_state_t;

spi_state_t state;

logic mosi_sync;
logic sclk_sync;
logic cs_n_sync;
logic sclk_prev;

// Shift registers collects until 8 bits are received, then the byte is processed
logic [2:0] bit_count;  // counts 8 bits
logic [7:0] rx_shift;   // Shift register for received bits
logic [7:0] tx_shift;   // Shift register for bits to transmit
logic [2:0] saved_addr; // to rememeber the address 

synchronizer sync_mosi (
    .clk(clk),
    .rst_n(rst_n),
    .async_in(mosi),
    .sync_out(mosi_sync)
);

synchronizer sync_sclk (
    .clk(clk),
    .rst_n(rst_n),
    .async_in(sclk),
    .sync_out(sclk_sync)
);

synchronizer sync_cs_n (
    .clk(clk),
    .rst_n(rst_n),
    .async_in(cs_n),
    .sync_out(cs_n_sync)
);

logic sclk_rise;
logic [7:0] received_byte;
logic byte_done;

assign sclk_rise = ~cs_n_sync & ~sclk_prev & sclk_sync;
// Append that fucker
assign received_byte = {rx_shift[6:0], mosi_sync};
// That fucker is full
assign byte_done = sclk_rise & (bit_count == 3'd7);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sclk_prev <= 1'b0;
    end else begin
        sclk_prev <= sclk_sync;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= WAIT_COMMAND;
        bit_count <= 3'd0;
        rx_shift <= 8'h00;
        tx_shift <= 8'h00;
        saved_addr <= 3'd0;
        miso <= 1'b0;
        write_enable <= 1'b0;
        imem_waddr <= 2'b00;
        imem_wdata <= 8'h00;
        cpu_start <= 1'b0;
        cpu_step <= 1'b0;
    end else begin
        write_enable <= 1'b0;
        cpu_start <= 1'b0;
        cpu_step <= 1'b0;

        if (cs_n_sync) begin           
            state <= WAIT_COMMAND;
            bit_count <= 3'd0;
            rx_shift <= 8'h00;
            tx_shift <= 8'h00;
            saved_addr <= 3'd0;
            miso <= 1'b0;
        end else if (sclk_rise) begin
            rx_shift <= received_byte;

            if (byte_done) begin
                bit_count <= 3'd0;

                case (state)
                    WAIT_COMMAND: begin
                        saved_addr <= received_byte[2:0];
                        
                        // Write/Read bit (the last one)
                        if (received_byte[7]) begin
                            state <= WAIT_WRITE_DATA;
                        end else begin
                            state <= SHIFT_READ_DATA;

                            // will be off by one so preload the first bit
                            case (received_byte[2:0])
                                ADDR_DMEM: begin
                                    miso <= dmem_value[7];
                                    tx_shift <= {dmem_value[6:0], 1'b0};
                                end
                                ADDR_PC: begin
                                    miso <= 1'b0;
                                    tx_shift <= {5'b00000, pc_value, 1'b0};
                                end
                                default: begin
                                    miso <= 1'b0;
                                    tx_shift <= 8'h00;
                                end
                            endcase
                        end
                    end

                    WAIT_WRITE_DATA: begin
                        state <= WAIT_COMMAND;

                        case (saved_addr)
                            ADDR_IMEM0, ADDR_IMEM1, ADDR_IMEM2, ADDR_IMEM3: begin
                                write_enable <= 1'b1;
                                imem_waddr <= saved_addr[1:0];
                                imem_wdata <= received_byte;
                            end
                            ADDR_CONTROL: begin
                                cpu_start <= received_byte[0];
                                cpu_step <= received_byte[1];
                            end
                            default: begin
                            end
                        endcase
                    end

                    SHIFT_READ_DATA: begin
                        state <= WAIT_COMMAND;
                    end

                    default: begin
                        state <= WAIT_COMMAND;
                    end
                endcase
            end else begin
                bit_count <= bit_count + 3'd1;

                if (state == SHIFT_READ_DATA) begin
                    miso <= tx_shift[7];
                    tx_shift <= {tx_shift[6:0], 1'b0};
                end
            end
        end
    end
end

// unused bit in rx_shift register
logic _unused;
assign _unused = &{rx_shift[7], 1'b0};

endmodule
