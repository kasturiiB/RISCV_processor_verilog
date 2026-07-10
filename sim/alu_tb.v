`timescale 1ns/1ps

module alu_tb;
    reg [31:0] a, b;
    reg [3:0] alu_ctrl; // EXPANDED TO 4 BITS
    wire [31:0] result;
    wire zero;

    // Instantiate DUT (Device Under Test)
    alu uut (
        .a(a), 
        .b(b), 
        .alu_ctrl(alu_ctrl), 
        .result(result), 
        .zero(zero)
    );

    initial begin
        $display("--- Starting ALU Hardware Verification ---");
        
        // 1. Test SLL (Shift Left Logical)
        // Shifting binary 0000...1111 (15) left by 2 should give 0011...1100 (60)
        a = 32'h0000_000F; 
        b = 32'd2;         
        alu_ctrl = 4'b0110; 
        #10;
        
        // 2. Test SRL (Shift Right Logical)
        // Shifting binary 0000...1111 (15) right by 2 should give 0000...0011 (3)
        a = 32'h0000_000F; 
        b = 32'd2;         
        alu_ctrl = 4'b0111; 
        #10;

        // 3. Test SRA (Shift Right Arithmetic)
        // Shifting -16 (FFFF_FFF0) right by 2 should preserve the sign bit and give -4 (FFFF_FFFC)
        a = 32'hFFFF_FFF0; 
        b = 32'd2;         
        alu_ctrl = 4'b1000; 
        #10;

        // 4. Test SLT (Set Less Than) - True condition
        // 10 is less than 20, so result should be 1
        a = 32'd10;
        b = 32'd20;
        alu_ctrl = 4'b1001; 
        #10;

        // 5. Test SLT (Set Less Than) - False condition
        // 20 is not less than 10, so result should be 0
        a = 32'd20;
        b = 32'd10;
        alu_ctrl = 4'b1001; 
        #10;

        $display("--- Simulation Complete ---");
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | A=%h B=%d Ctrl=%b | Result=%h Zero=%b", 
                 $time, a, b, alu_ctrl, result, zero);
    end
endmodule
