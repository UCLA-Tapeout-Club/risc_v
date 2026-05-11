module dmem (
    input logic clk,
    input logic rst_n,

    input logic write,
    input logic [7:0] alu_out,
    output logic [7:0] current_dmem_value // external item? idk how this works
);

logic [7:0] dmem_value;
assign current_dmem_value = dmem_value;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dmem_value <= 8'b0;
    end else begin
        if (write) dmem_value <= alu_out;
    end
end

endmodule