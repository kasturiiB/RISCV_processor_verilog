`timescale 1ns / 1ps
module control (
    input  [6:0] opcode,
    output reg regwrite, memread, memwrite, branch,
               alusrc, memtoreg, jump, jalr,
    output reg [1:0] aluop
);
    always @(*) begin
        regwrite=0; memread=0; memwrite=0; branch=0;
        alusrc=0; memtoreg=0; aluop=2'b00; jump=0; jalr=0;
        case (opcode)
            7'b0110011: begin regwrite=1; aluop=2'b10; end              // R-type
            7'b0010011: begin regwrite=1; alusrc=1; aluop=2'b10; end    // I-type ALU
            7'b0000011: begin regwrite=1; alusrc=1; memread=1;
                              memtoreg=1; aluop=2'b00; end              // lw
            7'b0100011: begin alusrc=1; memwrite=1; aluop=2'b00; end    // sw
            7'b1100011: begin branch=1; aluop=2'b01; end                // beq/bne
            7'b1101111: begin regwrite=1; jump=1; end                   // jal
            7'b1100111: begin regwrite=1; alusrc=1;
                              aluop=2'b00; jalr=1; end                  // jalr FIXED
        endcase
    end
endmodule
