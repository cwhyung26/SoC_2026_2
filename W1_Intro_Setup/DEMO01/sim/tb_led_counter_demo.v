`timescale 1ns / 1ps

// W1_S2 시뮬레이션 데모용 테스트벤치.
// 실제 1초 분주는 파형에서 확인하기엔 너무 길어서, 시뮬레이션 전용으로 분주값을 줄여서 관찰한다.
module tb_led_counter_demo;

    localparam CLK_PERIOD_NS = 8; // 125 MHz 근사치 (8ns 주기)

    reg clk;
    reg rst_n;
    wire [3:0] led;

    // 시뮬레이션에서는 1초를 기다릴 수 없으므로 TICK_MAX가 작아지도록
    // CLK_FREQ_HZ를 20으로 줄여서 tick을 자주 발생시킨다.
    led_counter_demo #(
        .CLK_FREQ_HZ(20)
    ) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .led   (led)
    );

    // 클럭 생성
    initial clk = 1'b0;
    always #(CLK_PERIOD_NS/2) clk = ~clk;

    initial begin
        rst_n = 1'b0;
        #(CLK_PERIOD_NS*5);
        rst_n = 1'b1;

        // led가 몇 번 증가하는 것을 파형으로 볼 수 있을 만큼 대기한다.
        #(CLK_PERIOD_NS*20*8);

        $finish;
    end

    initial begin
        $monitor("t=%0t rst_n=%b led=%b", $time, rst_n, led);
    end

endmodule
