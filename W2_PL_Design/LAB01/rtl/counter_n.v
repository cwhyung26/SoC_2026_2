`timescale 1ns / 1ps
// =============================================================================
// counter_n.v
// N-bit parameterized up-counter, reused from the prerequisite Verilog course
// (DE0 / Quartus). Behaviour is intentionally unchanged: a plain synchronous
// counter with an asynchronous reset and a clock-enable input.
//
//   clk      : counting clock (here: the 100 MHz output of Clocking Wizard)
//   rst      : asynchronous, active-high reset
//   en       : clock enable - count advances only on cycles where en == 1
//   count    : current value, WIDTH bits
//   max_tick : high for one enabled cycle when count is at MAX_VAL
// =============================================================================
module counter_n #(
    parameter WIDTH   = 8,
    parameter MAX_VAL = (1 << WIDTH) - 1
)(
    input                  clk,
    input                  rst,
    input                  en,
    output reg [WIDTH-1:0] count,
    output                 max_tick
);

    always @(posedge clk or posedge rst)
        if (rst)
            count <= {WIDTH{1'b0}};
        else if (en)
            count <= (count == MAX_VAL[WIDTH-1:0]) ?
                     {WIDTH{1'b0}} : count + 1'b1;

    assign max_tick = (count == MAX_VAL[WIDTH-1:0]) && en;

endmodule
