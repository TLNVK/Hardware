`timescale 1ns/1ps

module uart_tb;


    localparam CLOCK_FREQ = 50_000_000;
    localparam BAUD_RATE  = 115200;
    localparam CLK_PERIOD = 20;     // 50 MHz clock => 20 ns
    localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;
    localparam BIT_PERIOD = CLKS_PER_BIT * CLK_PERIOD;


    logic clk = 0;
    logic rst = 1;

    logic tx;
    logic rx;

    logic [7:0] tx_data;
    logic tx_start;
    logic tx_busy;

    logic [7:0] rx_data;
    logic rx_valid;

    uart_tx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut_tx (
        .clk(clk),
        .rst(rst),
        .data_in(tx_data),
        .start(tx_start),
        .tx(tx),
        .busy(tx_busy)
    );

    uart_rx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut_rx (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    // Loopback connection
    assign rx = tx;

    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $display("=== UART TESTBENCH START ===");

        repeat(5) @(posedge clk);
        rst = 0;

        send_byte(8'h55);  // 01010101
        send_byte(8'hA5);  // 10100101
        send_byte(8'h0F);  // 00001111
        send_byte(8'hFF);  // 11111111

        repeat(10000) @(posedge clk);

        $display("=== UART TESTBENCH DONE ===");
        $finish;
    end
    task send_byte(input logic [7:0] data);
        begin

            @(posedge clk);
            tx_data  = data;
            tx_start = 1'b1;
            @(posedge clk);
            tx_start = 1'b0;

            wait (tx_busy == 0);

            wait (rx_valid == 1);
            if (rx_data !== data) begin
                $error("[%0t] there's a mismatch! Sent %h, Received %h", $time, data, rx_data);
            end else begin
                $display("[%0t] perfect! Received %h", $time, rx_data);
            end
        end
    endtask

endmodule
