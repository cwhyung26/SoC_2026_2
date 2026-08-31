`timescale 1ns / 1ps

// W1_S2 Vivado 데모용 예제. 클럭을 분주해 4비트 카운터를 1초 간격으로 증가시킨다.
// 지난 학기 DE0/Quartus에서 만든 클럭 분주기 + 카운터와 동일한 구조다.
module led_counter_demo #(
    parameter CLK_FREQ_HZ = 125_000_000  // Cora Z7-07S PL 외부 클럭(추정치, 2주차에 실측값으로 확인)
) (
    input  wire       clk,     // 보드 외부 클럭 입력
    input  wire       rst_n,   // active-low 리셋 버튼 입력
    output reg  [3:0] led      // 온보드 LED 4개 출력
);

    localparam integer TICK_MAX = CLK_FREQ_HZ - 1; // 1초에 한 번 tick

    reg [31:0] tick_cnt;
    reg        tick;

    // 1) 클럭 분주 — CLK_FREQ_HZ번마다 한 번 tick을 1클럭 동안 세운다.
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

    // 2) tick이 발생할 때마다 4비트 카운터를 증가시켜 LED로 내보낸다.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            led <= 4'd0;
        else if (tick)
            led <= led + 4'd1;
    end

endmodule
