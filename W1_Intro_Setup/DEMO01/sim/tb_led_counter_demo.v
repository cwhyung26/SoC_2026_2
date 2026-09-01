`timescale 1ns / 1ps

// W1_S2 simulation demo testbench.
// The real 1-second divide is far too long to watch in a waveform, so for
// simulation only the divide value is shrunk to keep the run observable.
module tb_led_counter_demo;

    localparam CLK_PERIOD_NS = 8; // ~125 MHz (8 ns period)

    reg clk;
    reg rst_n;
    wire [3:0] led;

    // We cannot wait a full second in simulation, so drive CLK_FREQ_HZ down to 20
    // (small TICK_MAX) to make ticks happen often.
    led_counter_demo #(
        .CLK_FREQ_HZ(20)
    ) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .led   (led)
    );

    // clock generation
    initial clk = 1'b0;
    always #(CLK_PERIOD_NS/2) clk = ~clk;

    initial begin
        rst_n = 1'b0;
        #(CLK_PERIOD_NS*5);
        rst_n = 1'b1;

        // wait long enough to see led increment several times in the waveform
        #(CLK_PERIOD_NS*20*8);

        $finish;
    end

    initial begin
        $monitor("t=%0t rst_n=%b led=%b", $time, rst_n, led);
    end

endmodule
