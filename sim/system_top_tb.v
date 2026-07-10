`timescale 1ns / 1ps

module system_top_tb;
    reg clk;
    reg reset;
    reg uart_rx_in;
    wire uart_tx_out;

    // Instantiate system_top
    system_top uut (
        .clk (clk),
        .reset (reset),
        .uart_rx_in (uart_rx_in),
        .uart_tx_out(uart_tx_out)
    );

    // 100 MHz main hardware clock
    always #5 clk = ~clk;

    // - Dump ALL signals including monitor internals
    initial begin
        $dumpfile("system_top_tb.vcd");
        $dumpvars(0, system_top_tb);
    end

    // - Debug: print every time CPU writes to a register
    always @(posedge clk) begin
        if (uut.cpu_regwrite)
            $display("[CPU] t=%0t rd=x%0d alu_result=0x%08h",
                     $time, uut.cpu_rd, uut.cpu_alu_result);
    end

    // Debug: Trigger when the math finishes!
    always @(posedge clk) begin
        if (uut.mon_result_valid)
            $display("[MON] RESULT VALID A=%0d op=%s B=%0d result=%0d",
                     uut.mon_operand_A,
                     uut.mon_operator_char,
                     uut.mon_operand_B,
                     uut.mon_result);
    end

    // - UART byte sender task (868 clocks @ 100MHz = 115200 baud) -
    task send_byte;
        input [7:0] data;
        integer i;
        begin
            uart_rx_in = 0;
            #8680; // start bit
            for (i=0; i<8; i=i+1) begin
                uart_rx_in = data[i];
                #8680;
            end
            uart_rx_in = 1; // stop bit
            #8680;
        end
    endtask

    // - Main simulation sequence
    initial begin
        clk = 0;
        reset = 1;
        uart_rx_in = 1; // UART idle
        #100;
        reset = 0;
        $display("[SIM] Reset released. CPU booting...");
        
        // Wait for the Fibonacci boot sequence to finish
        #50000; 
        
        // --- FIBONACCI MEMORY DUMP ---
        $display("========================================");
        $display("BOOT SEQUENCE COMPLETE. MEMORY DUMP:");
        $display("Fib[0]  (Mem[0])  = %0d", uut.cpu_core.dmem.memory[0]);
        $display("Fib[1]  (Mem[4])  = %0d", uut.cpu_core.dmem.memory[1]);
        $display("Fib[2]  (Mem[8])  = %0d", uut.cpu_core.dmem.memory[2]);
        $display("Fib[3]  (Mem[12]) = %0d", uut.cpu_core.dmem.memory[3]);
        $display("Fib[4]  (Mem[16]) = %0d", uut.cpu_core.dmem.memory[4]);
        $display("Fib[5]  (Mem[20]) = %0d", uut.cpu_core.dmem.memory[5]);
        $display("Fib[6]  (Mem[24]) = %0d", uut.cpu_core.dmem.memory[6]);
        $display("Fib[7]  (Mem[28]) = %0d", uut.cpu_core.dmem.memory[7]);
        $display("Fib[8]  (Mem[32]) = %0d", uut.cpu_core.dmem.memory[8]);
        $display("Fib[9]  (Mem[36]) = %0d", uut.cpu_core.dmem.memory[9]);
        $display("========================================");
        
        // --- CALCULATOR TEST 1 
        // Let CPU reach its polling loop
        $display("[SIM] Sending Calculator Test 1...");
        send_byte(8'h37); // operand 1: '7'
        #200000;
        send_byte(8'h2D); // operator: '+' (Hex 2B)
        #200000;
        send_byte(8'h35); // operand 2: '5'
        #800000;

        // --- CALCULATOR TEST 2 (Testing the new '<' operation) ---
        $display("[SIM] Sending Calculator Test 2...");
        send_byte(8'h35); // operand 1: '7'
        #200000;
        send_byte(8'h3E); // operator: '<' (Hex 3C)
        #200000;
        send_byte(8'h34); // operand 2: '9' (7 is less than 9, output will be 1)
        #800000;
        // ========================================================
        // CHANGE THIS HEX CODE TO TEST DIFFERENT OPERATIONS:
        // 3C = Less Than (<)
        // 3E = Greater Than (>)
        // 3D = Equal To (=)
        // 2B = Addition (+)
        // ========================================================
        
       
        $display("[SIM] Done.");
        $finish;
    end
endmodule
