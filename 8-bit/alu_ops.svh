typedef enum logic [2:0] {
    ADD = 3'b00,
    SUB = 3'b001,
    RIGHT_SHIFT = 3'b010,
    LEFT_SHIFT = 3'b011,
    AND = 3'b100,
    OR = 3'b101,
    XOR = 3'b110,
    WRITE = 3'b111
} alu_ops;