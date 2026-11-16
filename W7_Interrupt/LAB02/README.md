# W7 LAB02 — PS Private Timer 1 ms tick과 잡 스케줄러 (Cora Z7-07S)

7주차 2교시(W7_S2) 실습 파일. 교재 본문은 [`../W7_S2_PS_Timer_Scheduler.md`](../W7_S2_PS_Timer_Scheduler.md)(제2장).

> **상태: 초안.** LAB01의 `.xsa`로 만든 Platform에서 `app_timer` 빌드까지 확인했다(`XPAR_XSCUTIMER_0_BASEADDR 0xf8f00600`, `XPAR_CPU_CORE_CLOCK_FREQ_HZ 650000000`, `XSLEEPTIMER_FREQ …/2`, `XPAR_XSCUTIMER_0_INTERRUPTS 0x13100d`). 보드에서는 아직 실행하지 않았다.

## 파일

```
LAB02/
└── src/timer_scheduler.c    # ISR은 tick + 1만, main의 if 세 개가 50 / 500 / 1000 ms 작업
```

## Vivado 작업이 없다

Private Timer는 Cortex-A9 코어 안에 있는 블록이라 Zynq 설정에 켤 것도, PL에 연결할 선도 없다. LAB01의 하드웨어(`gpio_irq`)와 Platform(`platform`)을 그대로 쓰고 **Application `app_timer`만 추가**한다. 타이머의 주소·인터럽트 번호는 `xparameters.h`에 이미 들어 있다.

## 타이머 숫자

| 항목 | 값 | 어디서 확인하나 |
|---|---|---|
| CPU 클럭 | 650 MHz | `xparameters.h` — `XPAR_CPU_CORE_CLOCK_FREQ_HZ 650000000` |
| 타이머 클럭 | CPU ÷ 2 = 325 MHz | `xtimer_config.h` — `XSLEEPTIMER_FREQ XPAR_CPU_CORE_CLOCK_FREQ_HZ/2` |
| 1 ms 로드값 | 325000 − 1 = **324999** | `LOAD`에서 0까지 세므로 `LOAD + 1`번 |
| 타이머 주소 | `0xF8F0_0600` | `XPAR_XSCUTIMER_0_BASEADDR` |
| GIC 분류 | PPI (LAB01의 AXI GPIO는 `IRQ_F2P`를 통한 SPI) | |

## 레지스터 (Private Timer, `0xF8F0_0600`)

| 오프셋 | 이름 | 쓰는 값 |
|---|---|---|
| `+0x0` | `LOAD` | `324999` |
| `+0x8` | `CONTROL` | `0x7` = bit0 시작 + bit1 auto-reload + bit2 인터럽트 (bit[15:8] 프리스케일러 0) |
| `+0xC` | `ISR` | ISR에서 `1`을 써서 만료 표시를 지운다 (write-1-to-clear) |

LED는 LAB01과 같이 `GPIO2_DATA`(+0x008)에 `Xil_Out32`로 직접 쓴다. 드라이버 함수는 GIC 등록(`XSetupInterruptSystem`) 하나뿐이다.

## 초기화 순서

1. `XSetupInterruptSystem(NULL, timer_isr, XPAR_XSCUTIMER_0_INTERRUPTS, XPAR_XSCUTIMER_0_INTERRUPT_PARENT, …)`
2. `Xil_Out32(TIMER_LOAD, 324999)`
3. `Xil_Out32(TIMER_CTRL, 0x7)` — 여기서부터 1 ms마다 인터럽트

LAB01과 같은 원칙(받을 준비를 먼저 하고 문을 연다). ISR은 `Xil_Out32(TIMER_ISR, 1)` + `tick = tick + 1`.

## 동작

| 주기 | 하는 일 | 깜빡임 |
|---|---|---|
| 50 ms | `led4[0]` 토글 | 1초에 10번 |
| 500 ms | `led4[1]` 토글 | 1초에 1번 |
| 1000 ms | `led4[2]` 토글 + PuTTY에 `t = N s` | 2초에 1번 |

세 작업이 LED 채널 하나를 나눠 쓰므로 현재 값을 `led` 변수에 두고 `led = led ^ 자기 비트`(`LED_50 0x1`, `LED_500 0x2`, `LED_1000 0x4`)로 자기 LED만 뒤집어 전체를 다시 쓴다. 스위치는 쓰지 않는다.

## 일부러 고장내 보기 (본문 2.8절)

| 실험 | 고치는 곳 | 예상 결과 |
|---|---|---|
| 1 | ISR에 `xil_printf("tick = %d\n\r", tick);` | 13자 ≈ 1.13 ms > 1 ms. UART 버퍼가 찬 뒤 ISR이 1 ms보다 길어져 main이 멈춘다. 터미널은 `tick` 줄로 쏟아진다 |
| 2 | `TIMER_CTRL`에 `0x7` 대신 `0x5` (auto-reload 끔) | tick이 1에서 멈춘다. 아무 작업도 실행되지 않는다 |
| 3 | 실험 1의 줄을 main `while (1)` 맨 앞으로 | 터미널은 쏟아지지만 LED 세 개는 같은 빠르기로 계속 깜빡이고 `t = N s`도 1초마다 나온다 |

실험 결과는 아직 보드에서 확인하지 않았다(확인할 것은 [`../IMG_CAPTURE_LIST.md`](../IMG_CAPTURE_LIST.md)).

## 과제 (본문 참조)

`app_homework` — GPIO 인터럽트와 타이머 인터럽트를 함께 등록하고, 1 ms tick으로 20 ms 디바운스. 인터럽트가 둘인데 `Concat`이 필요 없는 이유(SPI와 PPI는 GIC까지 가는 길이 다르다)를 설명한다.

## 다음 LAB

[`../LAB03/README.md`](../LAB03/README.md) — LAB01에서 붙인 ILA로 인터럽트 보기(제3장).
