`timescale 1ns/1ps

module result_monitor (
    input clk,
    input reset,
    input [4:0] rd,
    input regwrite,
    input [31:0] alu_result,
    output reg [31:0] operand_A,
    output reg [31:0] operand_B,
    output reg [7:0] operator_char,
    output reg [31:0] result,
    output reg result_valid
);
    reg result_locked; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            operand_A <= 0;
            operand_B <= 0;
            operator_char <= 0;
            result <= 0;
            result_valid <= 0;
            result_locked <= 0;
        end else begin
            result_valid <= 0;

            // x10 gets operand A (First step of a new calculation)
            if (regwrite && rd == 5'd10) begin
                operand_A <= alu_result;
                
                operand_B <= 32'b0;
                operator_char <= 8'b0;
                result <= 32'b0;
                
                result_locked <= 0; // Unlock the monitor for the new math result
            end

            // x24 gets operator ASCII char
            if (regwrite && rd == 5'd24)
                operator_char <= alu_result[7:0];

            // x11 gets operand B
            if (regwrite && rd == 5'd11)
                operand_B <= alu_result;

            // x6 gets the arithmetic result
            if (regwrite && rd == 5'd6 && !result_locked) begin
                result <= alu_result;
                result_valid <= 1;
                result_locked <= 1; // Lock the monitor so the print loop doesn't overwrite it
            end
        end
    end
endmodule
