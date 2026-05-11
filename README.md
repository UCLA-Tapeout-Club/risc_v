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

