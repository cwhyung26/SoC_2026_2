`timescale 1ns / 1ps

// W1_S2 Vivado demo. Divides the clock and increments a 4-bit counter once per second.
// Same structure as the clock divider + counter built last semester in DE0/Quartus.
module led_counter_demo #(
    parameter CLK_FREQ_HZ = 125_000_000  // Cora Z7-07S PL external clock (assumed; confirm measured value in week 2)
) (
    input  wire       clk,     // board external clock input (Cora Z7-07S: 125 MHz sysclk)
    input  wire       rst_n,   // active-low reset (mapped to a push-button in the XDC)
    output reg  [3:0] led      // 4-bit count; on Cora Z7-07S mapped to RGB LED channels (see XDC)
);

    localparam integer TICK_MAX = CLK_FREQ_HZ - 1; // one tick per second

    reg [31:0] tick_cnt;
    reg        tick;

    // 1) Clock divider: raise tick for one clock every CLK_FREQ_HZ clocks.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_cnt <= 32'd0;
            tick     <= 1'b0;
        end else if (tick_cnt == TICK_MAX) begin
            tick_cnt <= 32'd0;
            tick     <= 1'b1;
        end else begin
            tick_cnt <= tick_cnt + 32'd1;
            tick     <= 1'b0;
        end
    end

    // 2) On every tick, increment the 4-bit counter and drive it onto the LEDs.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            led <= 4'd0;
        else if (tick)
            led <= led + 4'd1;
    end

endmodule
