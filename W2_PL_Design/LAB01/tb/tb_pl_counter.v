`timescale 1ns / 1ps
// =============================================================================
// tb_pl_counter.v
// Minimal behavioural testbench for pl_counter.
//
// CLK_HZ / STEP_HZ are overridden small so that one tick happens every 10
// clock cycles - long enough to see the divider count and the 1-cycle tick,
// short enough that the 4-bit count value wraps quickly.
// =============================================================================
module tb_pl_counter;

    localparam integer CLK_PERIOD_NS = 10;   // 100 MHz-style clock

    reg         clk = 1'b0;
    reg         rst = 1'b1;
    wire [3:0]  count;
    wire        tick;
    wire [23:0] div_count;

    pl_counter #(
        .CLK_HZ  (1000),   // divide-by-10 -> tick every 10 clocks
        .STEP_HZ (100)
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .count     (count),
        .tick      (tick),
        .div_count (div_count)
    );

    always #(CLK_PERIOD_NS/2) clk = ~clk;

    initial begin
        rst = 1'b1;
        repeat (4) @(posedge clk);
        rst = 1'b0;

        // 400 cycles -> ~40 ticks -> count wraps 0..15 about 2.5 times
        repeat (400) @(posedge clk);

        $display("TB done: final count = %b", count);
        $finish;
    end

    initial $monitor("t=%0t rst=%b tick=%b div=%0d count=%b",
                     $time, rst, tick, div_count, count);

endmodule
