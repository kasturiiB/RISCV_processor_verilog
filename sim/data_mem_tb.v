`timescale 1ns/1ps

module data_mem_tb;

reg clk, we;
reg [31:0] addr, wd;
wire [31:0] rd;

data_mem uut (clk, we, addr, wd, rd);

always #5 clk = ~clk;

initial begin
   clk = 0;
   we = 1;

   addr = 0; wd = 55;
   #10;

   we = 0;
   #10;

   $display("Read Data = %d", rd);

   #10 $finish;
end

endmodule
