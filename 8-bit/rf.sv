module rf (
    input logic clk,
    input logic rst_n,

    input logic [1:0] rsd_addr,
    input logic [1:0] rs2_addr,

    input logic [7:0] write_data,

    output logic [1:0] rsd_data,
    output logic [1:0] rs2_data
);

logic [7:0] registers [4];

assign rsd_data = registers[rsd_addr];
assign rs2_data = registers[rs2_addr];

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        registers[0] <= 8'h00;
        registers[1] <= 8'h01;
        registers[2] <= 8'h02;
        registers[3] <= 8'h03;
    end else begin
        if (rsd_addr != 2'b00) registers[rsd_addr] <= write_data;
    end
end

endmodule