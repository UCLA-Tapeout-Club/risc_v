module regfile(
    input logic clock,
    input logic rst_n,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] write_data, // data to be written
    input logic regWrite, // bool from control which states if reg write is to be performed
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

logic [31:0] registers [32];
// logic [5:0] iter;

always_ff @(posedge clock or negedge rst_n) begin
    if (!rst_n) begin
        // note that int is just a number that is used to indicate how many 0's are 
        for (int iter = 0; iter < 32; i++) begin
            registers[iter] = 32'b0;
        end
    end else begin
        if (regWrite && rd != 5'b00000) begin // prevent writing to 0 register
            registers[rd] <= write_data;
        end
    end
end
    
assign rs1_data = registers[rs1];
assign rs2_data = registers[rs2];

endmodule