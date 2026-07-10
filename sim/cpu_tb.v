`timescale 1ns/1ps

module cpu_tb;

    reg clk;
    reg reset;

    // Instantiate CPU
    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        reset = 1;

        #10;
        reset = 0;

        // Run simulation long enough for program
        #200  $finish;
    end

endmodule
