`timescale 1ns / 1ps
`include "alu_ops.svh"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/11/2026 02:46:05 AM
// Design Name: 
// Module Name: complete_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module two_ins_sequence (

    );
    
    logic clk;
    logic rst_n;
    logic [7:0] in_ins [3:0];
    logic [7:0] rs2_data;
    logic [7:0] rd_data;
    
//    assign in_ins = {8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000};
    
    logic [7:0] dmem_out;
    logic [1:0] pc_out;
    logic [7:0] registers [4];
    
    logic [7:0] all_ins [9408];
    logic [7:0] all_ins2 [9408];
    
    logic[7:0] correct_xw[];
    
    logic [31:0] all_instructions = 9408; // we do one instruction, write to xw, and reset. square ^2 and ^3 for more complicated sequences of events
    
    logic [2:0] num_registers = 4;
    
    logic [3:0] num_instructions = 7;
    
    logic [0:31] initial_reg_vals = 32'h00010203;
    
    

    
    top DUT(
        .clk(clk), 
        .rst_n(rst_n), 
        .in_ins(in_ins), 
        .current_dmem_value(dmem_out),
        .rsd_data(rd_data),
        .rs2_data(rs2_data),
        .pc_out(pc_out),
        .registers(registers)
    );
    
//    initial begin
//        clk = 0;
//        rst_n = 0;
//    end
    
    always #20 clk = ~clk;
    
    logic[7:0] result = 0;
    logic [7:0] a;
    logic [7:0] b;
    logic [1:0] rd_sel;
    
    initial begin
        correct_xw = new[9408];
        in_ins = {8'b00000000, 8'b00000000, 8'b00000000, 8'b00000000};
        
        for (int i = 1; i < num_registers; i++) begin
            for (int j = 0; j < 2; j++) begin // for alternating between opcode 0 (R-type) and 1 (immediate)
                for (int k = 0; k < num_registers; k++) begin // alternate between all possible rs2 (initial values)
                    for (int l = 0; l < num_instructions; l++) begin // alternate between all instructions
                        initial_reg_vals = 32'h00010203;
                        result = 0;
                        a = initial_reg_vals[8*i +: 8];
                        b = (j ? k : initial_reg_vals[8*k +: 8]);
                        case (l)
                            ADD: result = a + b;
                            SUB: result = a - b;
                            RIGHT_SHIFT: result = a >> b[4:0];
                            LEFT_SHIFT: result = a << b[4:0];
                            AND: result = a & b;
                            OR: result = a | b;
                            XOR: result = a ^ b;
                            default: result = a;
                        endcase
                        
                        if (result < 0) begin
                            result = ~result + 1;
                        end
                        
//                        if (i == 3) begin
//                            $display("a is %d b is %d and correct_xw is %d", a, b, result);
//                        end
//                        correct_xw[(i-1) * 56 + j * 28 + k * 7 + l] = result;
//                        all_ins[(i-1) * 56 + j * 28 + k * 7 + l] = {j[0], i[1:0], k[1:0], l[2:0]};
                        
                        initial_reg_vals[8*i+:8] = result[7:0];
                        
                        for (int n = 0; n < 2; n++) begin // for alternating between opcode 0 (R-type) and 1 (immediate)
                            for (int m = 0; m < num_registers; m++) begin // alternate between all possible rs2 (initial values)
                                for (int r = 0; r < num_instructions; r++) begin // alternate between all instructions
                                    result = 0;
                                    a = initial_reg_vals[8*i +: 8];
                                    b = (n ? m : initial_reg_vals[8*m +: 8]);
                                    case (r)
                                        ADD: result = a + b;
                                        SUB: result = a - b;
                                        RIGHT_SHIFT: result = a >> b[4:0];
                                        LEFT_SHIFT: result = a << b[4:0];
                                        AND: result = a & b;
                                        OR: result = a | b;
                                        XOR: result = a ^ b;
                                        default: result = a;
                                    endcase
                                    
                                    if (result < 0) begin
                                        result = ~result + 1;
                                    end
                                    
//                                    if (i == 3) begin
//                                        $display("a is %d b is %d and correct_xw is %d", a, b, result);
//                                    end
                                    correct_xw[(i-1) * 3136 + j * 1568 + k * 392 + l * 56 + n * 28 + m * 7 + r] = result;
                                    all_ins2[(i-1) * 3136 + j * 1568 + k * 392 + l * 56 + n * 28 + m * 7 + r] = {n[0], i[1:0], m[1:0], r[2:0]};
                                    all_ins[(i-1) * 3136 + j * 1568 + k * 392 + l * 56 + n * 28 + m * 7 + r] = {j[0], i[1:0], k[1:0], l[2:0]};
                                    
                                end
                            end
                        end
                    end
                end
            end
        end
        
        #20 clk = 0; 
        
//        $display("At time %t: dmem=%d", $time, dmem_out);
        
        
        for(int i = 0; i < all_instructions; i++) begin
            rd_sel = i / 3136 + 1;
            in_ins[2] = {1'b1, rd_sel, 5'b11111};
            in_ins[1] = all_ins2[i];
            in_ins[0] = all_ins[i];
            
            $display("The correct value is %d", correct_xw[i]);
            
            rst_n = 0;
            #40 rst_n = 1; // reset and allow instruction to play out

            #130;
            $display("dmem rn is %d", dmem_out);
            
            if (correct_xw[i] != dmem_out) begin
                $display("CASE FAIL!!!!!!!!!");
                $finish;
            end
            #30;
            
        end
        
        $finish;
    end
endmodule
