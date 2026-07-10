`timescale 1ns/1ps

module alu_control_tb;

reg [1:0] aluop;
reg [2:0] funct3;
reg funct7_5;

wire [2:0] alu_ctrl;

// Instantiate DUT
alu_control uut (
    .aluop(aluop),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .alu_ctrl(alu_ctrl)
);

initial begin
    // Initialize
    aluop = 2'b00;
    funct3 = 3'b000;
    funct7_5 = 0;

    // -------- lw / sw (should ADD) --------
    #10 aluop = 2'b00; funct3 = 3'b000; funct7_5 = 0;

    // -------- beq (should SUB) --------
    #10 aluop = 2'b01; funct3 = 3'b000; funct7_5 = 0;

    // -------- R-type ADD --------
    #10 aluop = 2'b10; funct3 = 3'b000; funct7_5 = 0;

    // -------- R-type SUB --------
    #10 aluop = 2'b10; funct3 = 3'b000; funct7_5 = 1;

    // -------- Unknown funct (default case) --------
    #10 aluop = 2'b10; funct3 = 3'b111; funct7_5 = 0;

    // -------- Default aluop --------
    #10 aluop = 2'b11;

    #20 $finish;
end

// Monitor output
initial begin
    $monitor("Time=%0t | aluop=%b funct3=%b funct7_5=%b | alu_ctrl=%b",
              $time, aluop, funct3, funct7_5, alu_ctrl);
end

// Waveform dump
initial begin
    $dumpfile("alu_control_tb.vcd");
    $dumpvars(0, alu_control_tb);
end

endmodule
