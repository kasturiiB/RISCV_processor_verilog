`timescale 1ns/1ps

module PC__tb;

reg clk, reset;
reg [31:0] pc_next;
wire [31:0] pc;

pc uut (.clk(clk), .reset(reset), .pc_next(pc_next), .pc(pc));

always #5 clk = ~clk;

initial begin
   clk = 0;
   reset = 1;
   pc_next = 0;

   #10 reset = 0;

   #10 pc_next = 4;
   #10 pc_next = 8;
   #10 pc_next = 12;

   #20 $finish;
end

initial begin
   $monitor("Time=%0t | PC=%h", $time, pc);
end

endmodule
