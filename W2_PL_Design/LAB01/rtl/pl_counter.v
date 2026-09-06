`timescale 1ns / 1ps
// =============================================================================
// pl_counter.v
// Block Design "Module Reference" wrapper for the Week 2 PL lab (Cora Z7-07S).
//
//   - Receives the 100 MHz clock from Clocking Wizard (clk_out1).
//   - Builds a STEP_HZ clock-enable pulse (tick) WITHOUT creating a second
//     fabric clock - the counter keeps running on the 100 MHz clock and only
//     advances on the 1-cycle tick.
//   - Reuses counter_n from the prerequisite Verilog course.
//
// Cora Z7-07S has no usable LED bank, so this design has NO pinned data
// output. All observable signals (count, tick, div_count) are brought out
// here and connected to a System ILA in the Block Design; verification on
// real hardware is done from the ILA waveform in Hardware Manager.
// =============================================================================
module pl_counter #(
    parameter integer CLK_HZ  = 100_000_000,  // Clocking Wizard clk_out1
    parameter integer STEP_HZ = 10             // counter increments per second
)(
    input  wire        clk,
    input  wire        rst,                    // async, active-high
    output wire [3:0]  count,                  // 4-bit up-counter value
    output wire        tick,                   // 1-clk enable pulse, STEP_HZ
    output wire [23:0] div_count               // free-running divider counter
);

    // STEP_HZ = 10 with a 100 MHz clock -> divide by 10,000,000.
    localparam integer DIVIDE_COUNT = CLK_HZ / STEP_HZ;
    localparam integer DIV_WIDTH    = 24;      // clog2(10_000_000) = 24

    reg  [DIV_WIDTH-1:0] div_cnt = {DIV_WIDTH{1'b0}};
    wire                 tick_i;
    wire                 max_tick_unused;

    assign tick_i = (div_cnt == DIVIDE_COUNT - 1);

    always @(posedge clk or posedge rst) begin
        if (rst)          div_cnt <= {DIV_WIDTH{1'b0}};
        else if (tick_i)  div_cnt <= {DIV_WIDTH{1'b0}};
        else              div_cnt <= div_cnt + 1'b1;
    end

    counter_n #(
        .WIDTH  (4),
        .MAX_VAL(15)
    ) u_counter_n (
        .clk     (clk),
        .rst     (rst),
        .en      (tick_i),
        .count   (count),
        .max_tick(max_tick_unused)
    );

    assign tick      = tick_i;
    assign div_count = div_cnt;

endmodule
