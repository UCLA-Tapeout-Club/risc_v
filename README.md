modified 8-bit RISCV inspired ISA:

- 4 registers in register file
- 4 instructions in instruction memory
- 1 register in data memory

a single instruction is 8 bits.
ins[7] - op code. 0 - R-type, 1 - I-type
ins[6:5] - rd, the destination register.
ins[4:3] - rs2/imm
int[2:0] - alu operation.

in alu_ops.svh, we can see that the alu ops are defined as follows:

ADD = 3'b000,
SUB = 3'b001,
RIGHT_SHIFT = 3'b010,
LEFT_SHIFT = 3'b011,
AND = 3'b100,
OR = 3'b101,
XOR = 3'b110,
WRITE = 3'b111

where WRITE is a special case of the alu operation that doesn't modify the register values and writes the value at address rd to the single register in data memory.

on reset, registers in reg file are initialized to some constant value. %0 = 0 always, %1 = 1, %2 =2, %3 = 3.

modified data path diagram:
<img width="2640" height="1485" alt="shitty_riscv8" src="https://github.com/user-attachments/assets/b2c84609-035f-4f86-b6cb-0f190b55fb69" />

SPI 
MAC python script
-> RP2040 (receive command and send SPI bytes)
-> SPI module (receive bytes packet and write to IMEM)
-> CPU (run program)
-> SPI module (read DMEM output)
-> RP2040 (send output to MAC python script)

think of the RP2040 as the master (can probably write up some python code and connect it to the RP2040 pins)
and the SPI module is going to be the slave (the rtl im writing)

The spi module receives a packet when the chip select is low. That will consist of two bytes.
byte 1 is the command/address byte
byte 2 is the data byte (if applicable)

the spi module is going to support the following commands:
0x80 data -> write imem[0] = data
0x81 data -> write imem[1] = data
0x82 data -> write imem[2] = data
0x83 data -> write imem[3] = data
0x84 data -> control register, data[0] = cpu_start, data[1] = cpu_step
0x05 0x00 -> read dmem_value on miso  (for debug purpouses)
0x06 0x00 -> read pc_value on miso. (for debug purpouses)

why 0x8X? we are going to dedicate one bit for write and read and the last 4 digits to be the address 0-3

The SPI protocal has 3 states: A state to receive Command/Adress byte, a state to receive instruction data, a state to shift the instruction data onto the mosi bus 

overall structure:
cpu_spi_top
  ├── spi_slave
  │     └── synchronizer
  └── cpu_top
        ├── run_controller
        ├── pc
        ├── imem
        ├── control
        ├── rf
        ├── alu
        └── dmem