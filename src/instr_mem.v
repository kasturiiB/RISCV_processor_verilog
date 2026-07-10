`timescale 1ns/1ps

module instr_mem(
    input [31:0] addr,
    output [31:0] instr
);
    reg [31:0] memory [0:255];
    integer i;

    initial begin
        for (i=0; i<256; i=i+1) memory[i] = 32'h00000013; // NOP 

        // =========================================================
        // PART 1: BOOT SEQUENCE - FIBONACCI (Isolated to x20-x25)
        // =========================================================
        memory[0]  = 32'h00000a13; // addi x20, x0, 0   (Fib[0])
        memory[1]  = 32'h00100a93; // addi x21, x0, 1   (Fib[1])
        memory[2]  = 32'h00000b93; // addi x23, x0, 0   (Mem Addr)
        memory[3]  = 32'h014ba023; // sw x20, 0(x23)     
        memory[4]  = 32'h004b8b93; // addi x23, x23, 4    
        memory[5]  = 32'h015ba023; // sw x21, 0(x23)     
        memory[6]  = 32'h004b8b93; // addi x23, x23, 4    
        memory[7]  = 32'h02800c93; // addi x25, x0, 40  (Limit = 40)
        
        // --- Fib Loop (PC=32) ---
        memory[8]  = 32'h00000013; // NOP
        memory[9]  = 32'h015a0b33; // add x22, x20, x21 
        memory[10] = 32'h016ba023; // sw x22, 0(x23)     
        memory[11] = 32'h000a8a13; // addi x20, x21, 0  
        memory[12] = 32'h000b0a93; // addi x21, x22, 0  
        memory[13] = 32'h004b8b93; // addi x23, x23, 4    
        memory[14] = 32'h019b8463; // beq x23, x25, +8   
        memory[15] = 32'h02400067; // jalr x0, x0, 36   
        
        // JUMP TO CALCULATOR (Absolute jump to PC=80)
        memory[16] = 32'h05000067; // jalr x0, x0, 80 
        
        memory[17] = 32'h00000013; // NOP
        memory[18] = 32'h00000013; // NOP
        memory[19] = 32'h00000013; // NOP

        // =========================================================
        // PART 2: CALCULATOR (Starts at PC=80)
        // =========================================================
        memory[20] = 32'h10000093; // addi x1, x0, 256  (RX addr)
        memory[21] = 32'h0fc00113; // addi x2, x0, 252  (TX addr)
        
        // --- Read Operand 1 ---
        memory[22] = 32'h0000a183; // lw x3, 0(x1)
        memory[23] = 32'h1001f213; // andi x4, x3, 256
        memory[24] = 32'hfe020ce3; // beq x4, x0, -8
        memory[25] = 32'h0ff1f513; // andi x10, x3, 255 
        memory[26] = 32'h00012283; // lw x5, 0(x2)
        memory[27] = 32'h1002f293; // andi x5, x5, 256
        memory[28] = 32'hfe029ce3; // bne x5, x0, -8
        memory[29] = 32'h00a12023; // sw x10, 0(x2)     
        memory[30] = 32'hfd050513; // addi x10, x10, -48 
        
        // --- Read Operator ---
        memory[31] = 32'h0000a183; // lw x3, 0(x1)
        memory[32] = 32'h1001f213; // andi x4, x3, 256
        memory[33] = 32'hfe020ce3; // beq x4, x0, -8
        memory[34] = 32'h0ff1fc13; // andi x24, x3, 255 
        memory[35] = 32'h00012283; // lw x5, 0(x2)
        memory[36] = 32'h1002f293; // andi x5, x5, 256
        memory[37] = 32'hfe029ce3; // bne x5, x0, -8
        memory[38] = 32'h01812023; // sw x24, 0(x2)     
        
        // --- Read Operand 2 ---
        memory[39] = 32'h0000a183; // lw x3, 0(x1)
        memory[40] = 32'h1001f213; // andi x4, x3, 256
        memory[41] = 32'hfe020ce3; // beq x4, x0, -8
        memory[42] = 32'h0ff1f593; // andi x11, x3, 255 
        memory[43] = 32'h00012283; // lw x5, 0(x2)
        memory[44] = 32'h1002f293; // andi x5, x5, 256
        memory[45] = 32'hfe029ce3; // bne x5, x0, -8
        memory[46] = 32'h00b12023; // sw x11, 0(x2)     
        memory[47] = 32'hfd058593; // addi x11, x11, -48 
        
        // --- Operator Branch Decode ---
        memory[48] = 32'h02b00a93; // addi x21, x0, 43  ('+')
        memory[49] = 32'h015c1463; // bne x24, x21, +8  
        memory[50] = 32'h10400067; // jalr x0, x0, 260  (Jump to ADD)
        
        memory[51] = 32'h02d00a93; // addi x21, x0, 45  ('-')
        memory[52] = 32'h015c1463; // bne x24, x21, +8
        memory[53] = 32'h10c00067; // jalr x0, x0, 268  (Jump to SUB)
        
        memory[54] = 32'h03c00a93; // addi x21, x0, 60  ('<')
        memory[55] = 32'h015c1463; // bne x24, x21, +8
        memory[56] = 32'h11400067; // jalr x0, x0, 276  (Jump to SLT)
        
        memory[57] = 32'h03e00a93; // addi x21, x0, 62  ('>') 
        memory[58] = 32'h015c1463; // bne x24, x21, +8
        memory[59] = 32'h11c00067; // jalr x0, x0, 284  (Jump to SGT)
        
        memory[60] = 32'h03d00a93; // addi x21, x0, 61  ('=') 
        memory[61] = 32'h015c1463; // bne x24, x21, +8
        memory[62] = 32'h12400067; // jalr x0, x0, 292  (Jump to SEQ)
        
        memory[63] = 32'h13c00067; // jalr x0, x0, 316  (Default to MUL)
        memory[64] = 32'h00000013; // NOP 

        // --- Math Execution Blocks ---
        // ADD (260)
        memory[65] = 32'h00b50333; // add x6, x10, x11
        memory[66] = 32'h14000067; // jalr x0, x0, 320  -> Jump to Print
        
        // SUB (268)
        memory[67] = 32'h40b50333; // sub x6, x10, x11
        memory[68] = 32'h14000067; 
        
        // SLT (276) [A < B]
        memory[69] = 32'h00b52333; // slt x6, x10, x11
        memory[70] = 32'h14000067; 
        
        // SGT (284) [A > B] 
        memory[71] = 32'h00a5a333; // slt x6, x11, x10  
        memory[72] = 32'h14000067; 
        
        // =========================================================
        // *** THE BUG FIX: BYPASS THE MONITOR LOCK ***
        // SEQ (292) [A == B]
        // =========================================================
        memory[73] = 32'h00b51663; // bne x10, x11, 12 (If A!=B, jump to FALSE)
        memory[74] = 32'h00100313; // addi x6, x0, 1   (TRUE block: x6 = 1)
        memory[75] = 32'h14000067; // jalr x0, x0, 320 -> Jump to Print
        memory[76] = 32'h00000313; // addi x6, x0, 0   (FALSE block: x6 = 0)
        memory[77] = 32'h14000067; // jalr x0, x0, 320 -> Jump to Print
        memory[78] = 32'h00000013; // NOP (padding)
        
        // MUL (316)
        memory[79] = 32'h02b50333; // mul x6, x10, x11
        
        // --- Output Formatting & Division Loop (PC=320) ---
        memory[80] = 32'h00000413; // addi x8, x0, 0    (tens = 0)
        memory[81] = 32'h00a00493; // addi x9, x0, 10   
        memory[82] = 32'h00934863; // blt x6, x9, +16   -> Jump to [86] done
        memory[83] = 32'h00140413; // addi x8, x8, 1    (tens++)
        memory[84] = 32'h40930333; // sub x6, x6, x9    
        memory[85] = 32'h14800067; // jalr x0, x0, 328  -> Loop to [82]
        
        // --- Print Result ---
        memory[86] = 32'h03d00393; // addi x7, x0, 61   ('=')
        memory[87] = 32'h00012283; // lw x5, 0(x2)
        memory[88] = 32'h1002f293; // andi x5, x5, 256
        memory[89] = 32'hfe029ce3; // bne x5, x0, -8
        memory[90] = 32'h00712023; // sw x7, 0(x2) 
        
        memory[91] = 32'h00040c63; // beq x8, x0, +24   -> Skip tens if 0
        memory[92] = 32'h03040393; // addi x7, x8, 48   
        memory[93] = 32'h00012283; // lw x5, 0(x2)
        memory[94] = 32'h1002f293; // andi x5, x5, 256
        memory[95] = 32'hfe029ce3; // bne x5, x0, -8
        memory[96] = 32'h00712023; // sw x7, 0(x2)
        
        memory[97] = 32'h03030393; // addi x7, x6, 48   
        memory[98] = 32'h00012283; // lw x5, 0(x2)
        memory[99] = 32'h1002f293; // andi x5, x5, 256
        memory[100]= 32'hfe029ce3; // bne x5, x0, -8
        memory[101]= 32'h00712023; // sw x7, 0(x2)
        
        memory[102]= 32'h00d00393; // addi x7, x0, 13   ('\r')
        memory[103]= 32'h00012283; 
        memory[104]= 32'h1002f293; 
        memory[105]= 32'hfe029ce3; 
        memory[106]= 32'h00712023; 
        
        memory[107]= 32'h00a00393; // addi x7, x0, 10   ('\n')
        memory[108]= 32'h00012283; 
        memory[109]= 32'h1002f293; 
        memory[110]= 32'hfe029ce3; 
        memory[111]= 32'h00712023; 
        
        // Loop back to wait for next expression (Absolute jump to PC=88)
        memory[112] = 32'h05800067; // jalr x0, x0, 88      
    end

    assign instr = memory[addr[7:0]];
endmodule
