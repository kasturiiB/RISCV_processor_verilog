`timescale 1ns / 1ps

module uart_tx # (
    parameter CLKS_PER_BIT = 868 // 100MHz clock / 115200 Baud rate
) (
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    output reg tx,
    output reg tx_busy,
    output reg tx_done
);

    localparam IDLE      = 3'b000;
    localparam START_BIT = 3'b001;
    localparam DATA_BITS = 3'b010;
    localparam STOP_BIT  = 3'b011;
    localparam CLEANUP   = 3'b100;

    reg [2:0] state;
    reg [31:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] tx_shift;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state      <= IDLE;
            tx         <= 1'b1;
            tx_busy    <= 1'b0;
            tx_done    <= 1'b0;
            clk_count  <= 0;
            bit_index  <= 0;
            tx_shift   <= 8'b0;
        end else begin
            case(state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_done <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if(tx_start) begin
                        tx_busy <= 1'b1;
                        tx_shift <= tx_data;
                        state <= START_BIT;
                    end else tx_busy <= 1'b0;
                end
                START_BIT: begin
                    tx <= 1'b0;
                    if(clk_count < CLKS_PER_BIT - 1) clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                    end
                end
                DATA_BITS: begin
                    tx <= tx_shift[bit_index];
                    if(clk_count < CLKS_PER_BIT - 1) clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        if(bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end
                    end
                end
                STOP_BIT: begin
                    tx <= 1'b1;
                    if(clk_count < CLKS_PER_BIT - 1) clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        tx_done   <= 1'b1;
                        tx_busy   <= 1'b0;
                        state     <= CLEANUP;
                    end
                end
                CLEANUP: begin
                    tx_done <= 1'b0;
                    state   <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
