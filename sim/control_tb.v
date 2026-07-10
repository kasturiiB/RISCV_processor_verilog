`timescale 1ns/1ps

module control_tb;

reg [6:0] opcode;

wire regwrite;
wire memread;
wire memwrite;
wire branch;
wire alusrc;
wire memtoreg;
wire [1:0] aluop;

// Instantiate DUT
control uut (
    .opcode(opcode),
    .regwrite(regwrite),
    .memread(memread),
    .memwrite(memwrite),
    .branch(branch),
    .alusrc(alusrc),
    .memtoreg(memtoreg),
    .aluop(aluop)
);

initial begin
    // Initialize
    opcode = 7'b0000000;

    // R-type (add/sub)
    #10 opcode = 7'b0110011;

    // lw
    #10 opcode = 7'b0000011;

    // sw
    #10 opcode = 7'b0100011;

    // beq
    #10 opcode = 7'b1100011;

    // Unknown opcode (default case)
    #10 opcode = 7'b1111111;

    #20 $finish;
end

// Monitor output
initial begin
    $monitor("Time=%0t | opcode=%b | regwrite=%b memread=%b memwrite=%b branch=%b alusrc=%b memtoreg=%b aluop=%b",
              $time, opcode, regwrite, memread, memwrite, branch, alusrc, memtoreg, aluop);
end

// Optional waveform dump
initial begin
    $dumpfile("control_tb.vcd");
    $dumpvars(0, control_tb);
end

endmodule
