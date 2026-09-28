# 5주차 스크린샷 캡처 목록 — 7장

1~4주차에서 Vivado 프로젝트 생성·Vitis Platform/Application 생성을 여러 번 캡처했으므로, **5주차는 새로운 화면과 결과만** 캡처한다. New Project, Run Connection Automation, Make External, Address Editor, HDL Wrapper, XDC Import, I/O Planning, Export Hardware, Platform·Application 생성, 빌드 완료 화면은 **캡처하지 않고 글로만 안내**한다.

본문은 아래 파일명을 이미 참조하도록 작성되어 있다. 캡처해서 `img/`에 이 이름으로 저장하고, 본문 캡션 끝의 **`📷 *캡처 대기*`** 표시를 지우면 된다.

개념도 3개(`w5_polling_vs_interrupt.svg`, `w5_irq_path.svg`, `w5_tick_scheduler.svg`)는 이미 들어 있다.

## 1교시 — [W5_S1_AXI_GPIO_Interrupt.md](W5_S1_AXI_GPIO_Interrupt.md) (제1장)

| 파일명 | 그림 | 무엇을 담아야 하나 | 왜 남겼나 |
|---|---|---|---|
| `img/w5s1_01.png` | 그림 1-3 | `axi_gpio_0`의 `Re-customize IP` → `IP Configuration` 탭. **`Enable Interrupt` 체크박스가 켜진 상태**가 보이게. 채널 설정(Width 4/4)도 같은 화면에 | 5주차에 새로 추가되는 유일한 IP 설정 |
| `img/w5s1_02.png` | 그림 1-4 | PS `Re-customize IP` → `Interrupts` 페이지. `Fabric Interrupts` 체크 + `PL-PS Interrupt Ports`를 펼친 `IRQ_F2P[15:0]` 체크가 **둘 다** 보이게 | 학생이 처음 보는 화면. 두 단계를 다 해야 하는 것이 함정 |
| `img/w5s1_03.png` | 그림 1-5 | 완성된 블록 디자인 전체. PS·`ps7_0_axi_periph`·`rst_ps7_0_50M`·`axi_gpio_0`과 **`ip2intc_irpt` → `IRQ_F2P[0:0]` 연결선**이 보이게 | 이번 주의 핵심 회로. 이 선 하나가 주제다 |
| `img/w5s1_04.png` | 그림 1-6 | 빌드된 BSP의 `xparameters.h`에서 `XPAR_AXI_GPIO_0_INTERRUPT_PRESENT 0x1` 줄. **4주차 플랫폼의 `0x0`과 나란히** 찍으면 가장 좋다 | 체크박스가 하드웨어를 지나 헤더까지 전달됐다는 증거 |
| `img/w5s1_05.png` | 그림 1-7 | PuTTY 로그. **스위치를 건드리기 전에는 아무 줄도 없다가** 움직이면 `count = 2, sw = 1` 같은 줄이 찍히는 모습. 카운터가 1이 아니라 2 이상 뛰는 것이 보이면 더 좋다 | 폴링과의 결정적 차이(가만히 두면 출력이 없다) + 바운스 관찰의 근거 |

## 2교시 — [W5_S2_PS_Timer_Scheduler.md](W5_S2_PS_Timer_Scheduler.md) (제2장)

| 파일명 | 그림 | 무엇을 담아야 하나 | 왜 남겼나 |
|---|---|---|---|
| `img/w5s2_01.png` | 그림 2-1 | `xparameters.h`의 `XPAR_CPU_CORE_CLOCK_FREQ_HZ 650000000`과 `xtimer_config.h`의 `XSLEEPTIMER_FREQ ... /2`. 두 파일을 나란히 열어 한 장에 담으면 가장 좋다 | 로드값 324999의 근거. 매직 넘버를 BSP에서 확인하는 절차 |
| `img/w5s2_02.png` | 그림 2-3 | PuTTY 로그. `t = 1 s`, `t = 2 s` … 가 **1초 간격으로 한 줄씩** 찍히는 모습 | 1 ms tick이 맞았다는 증거. 초시계와 맞는지가 2교시 첫 확인 사항 |

## 있으면 좋은 추가 컷 (본문에 자리는 없지만 다음 개정에 넣을 수 있다)

- 2교시 실험 1(ISR에 `xil_printf` 삽입) 직후 터미널이 멈춘 화면 — "ISR은 짧게"의 가장 강한 증거
- 2교시 실험 3에서 터미널이 초당 20줄씩 쏟아지는데도 `led4[3]`은 1초에 한 번 정확히 깜빡이는 모습(동영상이면 더 좋다)
- 보드+shield 동작 사진 — 1교시는 shield LED 4개가 카운터 값을 2진수로 표시한 상태, 2교시는 `led4[3]`만 따로 깜빡이는 상태

> **HEIC 주의.** 휴대폰으로 찍은 사진은 `.HEIC`로 저장되는 경우가 많고, HEIC는 GitHub·마크다운에서 렌더링되지 않는다. 반드시 `.jpg`로 변환해서 넣는다(4주차 `w4s2_19`에서 같은 문제가 있었다).
