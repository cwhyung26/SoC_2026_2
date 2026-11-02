# W5 LAB02 — PS Private Timer 1 ms tick과 잡 스케줄러 (Cora Z7-07S)

5주차 2교시(W5_S2) 실습 파일. 교재 본문은 [`../W5_S2_PS_Timer_Scheduler.md`](../W5_S2_PS_Timer_Scheduler.md)(제2장).

> **상태: 초안, 실기기 미검증.** 캡처는 2장만 필요하다 — 자세한 목록은 [`../IMG_CAPTURE_LIST.md`](../IMG_CAPTURE_LIST.md).

## Vivado 작업이 없다 — LAB01의 하드웨어와 Platform을 그대로 쓴다

Cortex-A9 Private Timer는 **PS의 CPU 코어 안에 이미 들어 있는 블록**이다. Zynq 설정에 켤 체크박스가 없고, PL에 연결할 선도 없다. 그래서 이번 LAB은:

- Vivado를 열지 않는다. `lab03` 프로젝트도, 비트스트림도, XSA도 LAB01에서 만든 것을 그대로 쓴다.
- Vitis Platform도 새로 만들지 않는다. LAB01의 **`w5_platform`을 재사용**하고 **Application(`lab02_app`)만 추가**한다.

> **4주차와 대비되는 지점이다.** 4주차는 LAB01·LAB02의 하드웨어가 달라서(AXI GPIO 1개 → 2개) Platform을 두 개 만들어야 했고, Application 생성 시 어느 Platform을 고르는지가 함정이었다. 5주차는 두 LAB이 같은 하드웨어를 쓰므로 Platform이 하나다. **하드웨어가 바뀌었을 때만 Platform을 새로 만든다** — Platform과 Application을 나누어 놓은 이유를 보여주는 대비이므로 수업에서 짚고 넘어간다.

`xscutimer.h`를 쓰기 위해 BSP 설정을 바꿀 필요도 없다. standalone BSP는 PS 주변장치 드라이버를 전부 포함하므로 LAB01에서 만든 플랫폼에 이미 들어 있다(4주차 `lab02_platform`에서도 `.../bsp/include/xscutimer.h`가 확인된다). PL의 IP는 Vivado 설계에 있어야만 드라이버가 생기지만, PS 주변장치는 칩에 항상 있으므로 항상 포함된다.

```
LAB02/
└── src/
    └── timer_scheduler.c    # 1 ms tick ISR + main의 잡 스케줄러(50/500/1000 ms)
```

## 이번 LAB의 설계

ISR은 `tick = tick + 1` 하나만 하고, main의 `while(1)` 안에서 `if` 세 개가 각자 "때가 되었는지"를 판단한다. LED 4개를 두 작업이 비트로 나눠 쓴다.

| 주기 | 하는 일 | 쓰는 LED |
|---|---|---|
| 50 ms | 스위치 `sw4[2:0]` → LED | `led4[2:0]` |
| 500 ms | LED 하나 토글 (1초에 한 번 깜빡) | `led4[3]` |
| 1000 ms | 터미널에 `t = N s, sw = N` 한 줄 | — |

## 핵심 포인트

- **`usleep`의 세 가지 문제**: 블로킹(쉬는 동안 아무것도 못 한다) / 주기 혼재(작업마다 다른 주기를 주기 어렵다) / 누적 오차(작업 실행시간이 주기에 더해져 뒤로 밀린다). 타이머는 CPU가 무엇을 하든 독립적으로 세므로 세 문제가 함께 사라진다.
- **PPI vs SPI** — 이번 LAB의 가장 중요한 대비. Private Timer는 코어 전용 **PPI**로 GIC에 직접 들어가고, LAB01의 AXI GPIO는 `IRQ_F2P`를 통한 **SPI**로 들어간다. 경로가 다른데도 **ISR을 등록하고 pending을 지우는 절차는 완전히 같다**(`XSetupInterruptSystem()`을 양쪽에서 똑같이 쓴다). 과제에서 인터럽트 두 개를 함께 쓸 때 `Concat`이 필요 없는 이유가 바로 이 경로 차이다.
- **타이머 클럭은 CPU 클럭의 1/2 = 325 MHz.** 외울 값이 아니라 BSP에서 확인할 값이다. `xtimer_config.h`에 `XSLEEPTIMER_FREQ = XPAR_CPU_CORE_CLOCK_FREQ_HZ/2`로 적혀 있고, `xparameters.h`의 `XPAR_CPU_CORE_CLOCK_FREQ_HZ`가 **650000000**이다. Cora Z7-07S는 흔히 보이는 667 MHz가 아니라 **650 MHz**다.
- **1 ms 로드값 = 324999.** LOAD에서 0까지 세므로 실제 카운트는 `LOAD + 1`이다. 코드에는 `#define LOAD_1MS 324999`로 한 번만 쓰고, 어디서 나온 숫자인지 주석으로 남긴다.
- **auto-reload가 없으면 tick이 한 번에 끝난다.** `XScuTimer_EnableAutoReload()`를 켜면 0에 닿는 순간 하드웨어가 LOAD를 다시 집어넣는다.
- **초기화 순서**: LookupConfig → CfgInitialize → **ISR 등록** → SetPrescaler → LoadTimer → EnableAutoReload → EnableInterrupt → **Start**. LAB01과 같은 원칙(받을 준비를 먼저 하고 문을 연다)이다.
- **작업 하나 = `if` 하나.** `if (tick - t50 >= 50) { t50 = tick; ... }` 형태를 세 번 반복한 것이 스케줄러 전부다. 작업을 추가하려면 `if`를 하나 더 쓰고, 주기를 바꾸려면 숫자만 고친다. 각 작업이 자기 `t` 변수만 보므로 서로 간섭하지 않는다.
- **출력 채널을 두 작업이 공유한다.** `XGpio_DiscreteWrite`는 채널 4비트를 한꺼번에 덮어쓰므로, 현재 LED 값을 `led` 변수에 기억해 두고 각 작업이 **자기 비트만** 바꿔서 전체를 다시 쓴다(`SW_BITS`=`0x7`, `BEAT_BIT`=`0x8`). 하나의 출력 레지스터를 여러 작업이 나눠 쓸 때 늘 나오는 문제이고 해법도 늘 이 형태다.
- **`XScuTimer_IsExpired()`와 `XGpio_InterruptGetStatus()`를 생략했다.** ISR이 인터럽트 하나에만 연결되어 있으므로, 불렸다는 것 자체가 원인을 말해 준다. 한 ISR이 여러 원인을 처리해야 할 때 비로소 필요해지는 코드다.
- **ISR에 `xil_printf`를 넣으면 시스템이 선다.** 115200 baud에서 한 문자가 약 87 µs이므로 `tick\n\r` 한 줄도 약 520 µs다. tick 주기가 1 ms이니 절반 이상을 출력에 쓰게 된다. 본문 2.8절 실험 1에서 일부러 재현하고, **같은 무게의 작업을 main(50 ms 작업)에 두면 시스템이 멈추지 않고 터미널만 시끄러워진다**는 대비(실험 3)까지 확인한다. 그 상황에서도 `led4[3]`이 1초에 한 번 정확히 깜빡이는 것이 tick의 정확성을 보여 준다.
- **정수 오버플로는 이번 실습 범위에서 문제가 되지 않는다.** `tick - t50 >= 50` 형태는 `tick`이 수십 일 누적되면 깨질 수 있어, 실무에서는 `unsigned` 뺄셈 관용구를 쓴다. 본문에 참고로만 적어 두고 코드는 단순한 형태를 유지했다.

## 검증 필요

- **타이머 클럭이 정말 325 MHz인지 실측 확인.** `xtimer_config.h`의 `XSLEEPTIMER_FREQ`를 근거로 CPU 650 MHz의 1/2로 계산했다. 실행 시 `t = N s` 줄이 초시계와 일치하는지(=tick이 정확히 1 ms인지) 확인한다. **어긋나면 `LOAD_1MS`를 2배 또는 1/2로 조정해야 하므로, 이 확인이 2교시에서 가장 먼저 할 일이다.**
- `XPAR_XSCUTIMER_0_BASEADDR`(`0xf8f00600`)로 `XScuTimer_LookupConfig()`가 정상 동작하는지. 4주차 플랫폼의 `xscutimer_g.c`에 이 주소와 `interrupts 0x13100d`가 들어 있는 것은 확인했다.
- `XScuTimer_EnableInterrupt()` 없이도 인터럽트가 오는지(오면 안 된다). 순서 설명의 근거가 된다.
- `XScuTimer_SetPrescaler(&timer, 0)`가 필요한지 확인한다. 리셋 직후 프리스케일러는 0이지만 **BSP의 `usleep()`이 같은 타이머를 쓰기 때문에** 명시적으로 넣어 두었다.
- 실험 1(ISR에 `xil_printf`)에서 **정확히 어떤 증상**이 나타나는지 — 완전 정지인지, 극도로 느려지는지. 본문 서술을 실측 증상에 맞춘다.
- LED 비트 분할(`led4[2:0]` 스위치 / `led4[3]` 하트비트)이 눈으로 명확히 구분되는지. 애매하면 하트비트를 `led4[0]`으로 옮기거나 작업을 두 개로 줄이는 것을 고려한다.

## 과제 (본문 참조)

5주차 두 장을 하나의 프로그램으로 합친다 — GPIO 인터럽트 + 타이머 인터럽트를 함께 등록하고, **1 ms tick으로 LAB01의 바운스 문제를 해결**(20 ms 디바운스)한다. 하드웨어와 Platform은 그대로이고 Application(`homework_app`)만 새로 만든다. `Concat`이 필요 없는 이유를 설명하는 것이 이 과제의 핵심 질문이다.
