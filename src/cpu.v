`timescale 1ns / 1ps

module cpu (
    input clk,
    input reset,
    input [31:0] in_read_data,
    output [31:0] out_alu_result,
    output [31:0] out_write_data,
    output out_memwrite,
    output out_memread,
    output [4:0] out_rd,
    output out_regwrite,
    output [31:0] out_rd1,
    output [31:0] out_rd2,
    output [31:0] out_wd
);

    wire [31:0] pc, pc_next, instr;
    wire regwrite, memread, memwrite, branch, alusrc, memtoreg, jump, jalr;
    wire [1:0] aluop;
    
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd  = instr[11:7];
    
    wire [31:0] rd1, rd2, wd;
    wire [31:0] imm, alu_in2, alu_result;
    wire [3:0] alu_ctrl;
    wire [31:0] dmem_data, final_mem_data;
    wire zero;
    
    wire [2:0] funct3 = instr[14:12];
    
    // --- FIXED: Added comprehensive branch decoding ---
    wire is_beq = (funct3 == 3'b000);
    wire is_bne = (funct3 == 3'b001);
    wire is_blt = (funct3 == 3'b100);
    
    // BLT is true if A < B, which means (A - B) is negative.
    // We check this by looking at the sign bit (bit 31) of the ALU result.
    wire branch_cond = is_beq ? zero :
                       is_bne ? !zero :
                       is_blt ? alu_result[31] : 1'b0;
                       
    wire pcsrc       = branch & branch_cond;
    
    wire [31:0] pc_plus4  = pc + 4;
    wire [31:0] pc_branch = pc + imm;
    wire [31:0] pc_jump   = pc + imm;

    // Next PC logic
    assign pc_next = jalr  ? (alu_result & 32'hFFFFFFFE) :
                     jump  ? pc_jump :
                     pcsrc ? pc_branch :
                     pc_plus4;

    assign alu_in2 = alusrc ? imm : rd2;
    assign final_mem_data = (alu_result >= 32'd252) ? in_read_data : dmem_data;
    
    // Write-back logic
    assign wd = (jump || jalr) ? pc_plus4 :
                memtoreg       ? final_mem_data :
                alu_result;

    // Original outputs
    assign out_alu_result = alu_result;
    assign out_write_data = rd2;
    assign out_memwrite   = memwrite;
    assign out_memread    = memread;

    // Monitor outputs
    assign out_rd       = rd;
    assign out_regwrite = regwrite;
    assign out_rd1      = rd1;
    assign out_rd2      = rd2;
    assign out_wd       = wd;

    // --- Sub-modules ---

    pc pc_inst (
        .clk(clk), .reset(reset), .enable(1'b1),
        .pc_next(pc_next), .pc(pc)
    );

    instr_mem imem (
        .addr(pc[31:2]), 
        .instr(instr)
    );

    control ctrl (
        .opcode(instr[6:0]),
        .regwrite(regwrite), .memread(memread), .memwrite(memwrite),
        .branch(branch), .alusrc(alusrc), .memtoreg(memtoreg),
        .aluop(aluop), .jump(jump), .jalr(jalr)
    );

    reg_file rf (
        .clk(clk), .we(regwrite),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .wd(wd), .rd1(rd1), .rd2(rd2)
    );

    imm_gen ig (
        .instr(instr), 
        .imm(imm)
    );

    // ALU Control with I-Type immediate masking
    wire is_rtype = (instr[6:0] == 7'b0110011);
    alu_control alu_ctrl_unit (
        .aluop(aluop), 
        .funct3(funct3),
        .funct7_bit5(is_rtype ? instr[30] : 1'b0),
        .funct7_bit0(is_rtype ? instr[25] : 1'b0),
        .alu_ctrl(alu_ctrl)
    );

    alu alu_inst (
        .a(rd1), .b(alu_in2),
        .alu_ctrl(alu_ctrl),
        .result(alu_result), .zero(zero)
    );

    wire dmem_we = memwrite && (alu_result < 32'd252);
    data_mem dmem (
        .clk(clk), .we(dmem_we),
        .addr(alu_result),
        .wd(rd2), .rd(dmem_data)
    );

endmodule
