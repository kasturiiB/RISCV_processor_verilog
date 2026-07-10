`timescale 1ns/1ps

module reg_file_tb;

reg clk, we;
reg [4:0] rs1, rs2, rd;
reg [31:0] wd;
wire [31:0] rd1, rd2;

reg_file uut (clk, we, rs1, rs2, rd, wd, rd1, rd2);

always #5 clk = ~clk;

initial begin
   clk = 0;
   we = 1;

   rd = 1; wd = 10;
   #10;

   rd = 2; wd = 20;
   #10;

   we = 0;
   rs1 = 1; rs2 = 2;
   #10;

   $finish;
end

initial begin
   $monitor("rd1=%d rd2=%d", rd1, rd2);
end

endmodule
