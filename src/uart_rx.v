`timescale 1ns/1ps

module uart_rx # (
    parameter CLKS_PER_BIT = 868 // 100MHz clock / 115200 Baud rate
) (
    input clk,
    input rst,
    input rx,
    output reg [7:0] rx_data,
    output reg rx_done
);

    localparam IDLE      = 3'b000;
    localparam START_BIT = 3'b001;
    localparam DATA_BITS = 3'b010;
    localparam STOP_BIT  = 3'b011;
    localparam CLEANUP   = 3'b100;

    reg [2:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] rx_shift;

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            rx_shift  <= 0;
            rx_data   <= 0;
            rx_done   <= 0;
        end else begin
            case(state)
                IDLE: begin
                    rx_done   <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if(rx == 0) state <= START_BIT;
                end
                START_BIT: begin
                    if(clk_count == (CLKS_PER_BIT-1)/2) begin
                        if(rx == 0) begin
                            clk_count <= 0;
                            state <= DATA_BITS;
                        end else state <= IDLE;
                    end else clk_count <= clk_count + 1;
                end
                DATA_BITS: begin
                    if(clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_shift[bit_index] <= rx;
                        if(bit_index < 7) bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state <= STOP_BIT;
                        end
                    end
                end
                STOP_BIT: begin
                    if(clk_count < CLKS_PER_BIT-1) clk_count <= clk_count + 1;
                    else begin
                        rx_data   <= rx_shift;
                        rx_done   <= 1'b1;
                        clk_count <= 0;
                        state     <= CLEANUP;
                    end
                end
                CLEANUP: begin
                    rx_done <= 1'b0;
                    state   <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
