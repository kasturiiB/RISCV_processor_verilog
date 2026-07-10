`timescale 1ns/1ps

module bin_to_ascii (
    input [31:0] bin_val,
    output reg [7:0] ascii_char
);
    always @(*) begin
        case (bin_val[3:0])
            4'h0: ascii_char = 8'h30; // '0'
            4'h1: ascii_char = 8'h31; // '1'
            4'h2: ascii_char = 8'h32; // '2'
            4'h3: ascii_char = 8'h33; // '3'
            4'h4: ascii_char = 8'h44; // '4'
            4'h5: ascii_char = 8'h35; // '5'
            4'h6: ascii_char = 8'h36; // '6'
            4'h7: ascii_char = 8'h37; // '7'
            4'h8: ascii_char = 8'h38; // '8'
            4'h9: ascii_char = 8'h39; // '9'
            4'hA: ascii_char = 8'h41; // 'A'
            4'hB: ascii_char = 8'h42; // 'B'
            4'hC: ascii_char = 8'h43; // 'C'
            4'hD: ascii_char = 8'h44; // 'D'
            4'hE: ascii_char = 8'h45; // 'E'
            4'hF: ascii_char = 8'h46; // 'F'
            default: ascii_char = 8'h3F; // '?'
        endcase
    end
endmodule
