`timescale 1ns / 1ps

module system_top #(
    parameter CLKS_PER_BIT = 868
) (
    input  clk,
    input  reset,
    input  uart_rx_in,
    output uart_tx_out
);

    // ── CPU signals ──────────────────────────────────────────────────
    wire [31:0] cpu_alu_result;
    wire [31:0] cpu_write_data;
    wire        cpu_memwrite;
    wire        cpu_memread;
    reg  [31:0] cpu_read_data;

    // ── New monitor wires from CPU internals ─────────────────────────
    wire [4:0]  cpu_rd;
    wire        cpu_regwrite;
    wire [31:0] cpu_rd1;
    wire [31:0] cpu_rd2;

    // ── UART signals ─────────────────────────────────────────────────
    wire [7:0]  ascii_to_send;
    wire        tx_start;
    wire        tx_busy;
    wire        tx_done;
    wire [7:0]  rx_data_out;
    wire        rx_done_flag;

    // ── MMIO state ───────────────────────────────────────────────────
    reg  [7:0]  rx_buffer;
    reg         rx_data_ready;

    wire is_uart_tx_address = (cpu_alu_result == 32'd252);
    wire is_uart_rx_address = (cpu_alu_result == 32'd256);
    wire uart_write_trigger  = cpu_memwrite && is_uart_tx_address;

    // ── MMIO read mux ────────────────────────────────────────────────
    always @(*) begin
        if (is_uart_rx_address)
            cpu_read_data = {23'b0, rx_data_ready, rx_buffer};
        else if (is_uart_tx_address)
            cpu_read_data = {23'b0, tx_busy, 8'b0};
        else
            cpu_read_data = 32'b0;
    end

    // ── Synchronous RX Flag Logic (No dropped bytes) ─────────────────
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_buffer     <= 8'd0;
            rx_data_ready <= 1'b0;
        end else begin
            if (rx_done_flag) begin
                rx_buffer     <= rx_data_out;
                rx_data_ready <= 1'b1;
            end else if (is_uart_rx_address && cpu_memread) begin
                rx_data_ready <= 1'b0;
            end
        end
    end

    assign tx_start      = uart_write_trigger & ~tx_busy;
    assign ascii_to_send = cpu_write_data[7:0];

    // ── CPU instance (Fully Synchronous 100 MHz) ─────────────────────
    cpu cpu_core (
        .clk           (clk),          // <-- Running on Main Clock
        .reset         (reset),
        .in_read_data  (cpu_read_data),
        .out_alu_result(cpu_alu_result),
        .out_write_data(cpu_write_data),
        .out_memwrite  (cpu_memwrite),
        .out_memread   (cpu_memread),
        .out_rd        (cpu_rd),
        .out_regwrite  (cpu_regwrite),
        .out_rd1       (cpu_rd1),
        .out_rd2       (cpu_rd2)
    );

    // ── Result monitor instance ──────────────────────────────────────
    wire [31:0] mon_operand_A;
    wire [31:0] mon_operand_B;
    wire [7:0]  mon_operator_char;
    wire [31:0] mon_result;
    wire        mon_result_valid;

    result_monitor monitor (
        .clk          (clk),           // <-- Running on Main Clock
        .reset        (reset),
        .rd           (cpu_rd),
        .regwrite     (cpu_regwrite),
        .alu_result   (cpu_alu_result),
        .operand_A    (mon_operand_A),
        .operand_B    (mon_operand_B),
        .operator_char(mon_operator_char),
        .result       (mon_result),
        .result_valid (mon_result_valid)
    );

    // ── UART RX ──────────────────────────────────────────────────────
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) receiver (
        .clk    (clk),
        .rst    (reset),
        .rx     (uart_rx_in),
        .rx_data(rx_data_out),
        .rx_done(rx_done_flag)
    );

    // ── UART TX ──────────────────────────────────────────────────────
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) transmitter (
        .clk     (clk),
        .rst     (reset),
        .tx_start(tx_start),
        .tx_data (ascii_to_send),
        .tx      (uart_tx_out),
        .tx_busy (tx_busy),
        .tx_done (tx_done)
    );

endmodule
