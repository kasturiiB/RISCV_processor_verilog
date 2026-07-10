`timescale 1ns / 1ps

module alu_control (
    input [1:0] aluop,
    input [2:0] funct3,
    input funct7_bit5, // instr[30]: distinguishes SUB/ADD and SRA/SRL
    input funct7_bit0, // instr[25]: distinguishes MUL from ADD
    output reg [3:0] alu_ctrl // EXPANDED TO 4 BITS
);

    always @(*) begin
        if (aluop == 2'b00) alu_ctrl = 4'b0000; // lw/sw -> ADD
        else if (aluop == 2'b01) alu_ctrl = 4'b0001; // branch -> SUB
        else begin // aluop == 2'b10 (R-type and I-type ALU)
            case (funct3)
                3'b000: begin
                    if (funct7_bit0) alu_ctrl = 4'b0100; // MUL 
                    else if (funct7_bit5) alu_ctrl = 4'b0001; // SUB 
                    else alu_ctrl = 4'b0000; // ADD / ADDI
                end
                3'b111: alu_ctrl = 4'b0010; // AND / ANDI
                3'b110: alu_ctrl = 4'b0011; // OR / ORI
                3'b100: alu_ctrl = 4'b0101; // DIV
                
                3'b001: alu_ctrl = 4'b0110; // SLL / SLLI (Shift Left Logical)
                3'b101: begin
                    if (funct7_bit5) alu_ctrl = 4'b1000; // SRA / SRAI (Shift Right Arithmetic)
                    else alu_ctrl = 4'b0111; // SRL / SRLI (Shift Right Logical)
                end
                3'b010: alu_ctrl = 4'b1001; // SLT / SLTI (Set Less Than)
                
                default: alu_ctrl = 4'b0000;
            endcase
        end
    end
endmodule
