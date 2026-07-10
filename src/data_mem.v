module data_mem (
    input clk,
    input we,
    input [31:0] addr,
    input [31:0] wd,
    output [31:0] rd
);

    reg [31:0] memory [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    always @(posedge clk) begin
        if (we)
            memory[addr[9:2]] <= wd;
    end

    assign rd = memory[addr[9:2]];

endmodule
