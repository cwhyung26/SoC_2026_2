# 7주차 스크린샷 캡처 목록

본문은 아래 파일명을 이미 참조하도록 작성되어 있다. 캡처해서 `img/`에 이 이름으로 저장하고, 본문 캡션 끝의 **`📷 *캡처 대기*`** 표시를 지우면 된다. 파일명에 설명을 붙여 넣어 주면(예: `스크린샷 … (clear 없음).png`) 그 내용에 맞춰 이름을 바꾸고 위치를 잡는다.

개념도(`img/w7_polling_vs_interrupt.svg`, `w7_irq_path.svg`, `w7_tick_scheduler.svg`, `w7_ila_irq.svg` — 그림 1-1, 1-2, 2-3, 3-3)는 이미 들어 있으므로 캡처하지 않는다.

4~6주차에 캡처한 화면(New Project, Run Connection Automation, Make External, Address Editor, Debug 표시, HDL Wrapper, XDC 추가, Export, Vitis Platform·Application 생성, Hardware Manager 연결)은 다시 캡처하지 않는다. **이번 주에 처음 나오거나 내용이 달라지는 화면과 결과만** 캡처한다.

## 1교시 — [W7_S1_AXI_GPIO_Interrupt.md](W7_S1_AXI_GPIO_Interrupt.md) (제1장)

| 파일명 | 그림 | 담을 내용 | 상태 |
|---|---|---|---|
| `img/w7s1_01.png` | 그림 1-3 | New Project — `gpio_irq`, 위치 `…/week7/vivado_prj` | ⚠️ 다시 찍기 — 지금 화면은 위치가 `…/week7` |
| `img/w7s1_02.png` | 그림 1-4 | Run Block Automation 직후 PS — `M_AXI_GP0`이 이미 있음 | ✅ |
| `img/w7s1_03.png` | 그림 1-5 | PS `Zynq Block Design` 화면에 `M_AXI_GP0`·`IRQ`·GIC 표시(빨간 상자는 편집으로 추가) | ✅ |
| `img/w7s1_04.png` | 그림 1-6 | PS `Re-customize IP` → `Interrupts`. `Fabric Interrupts`와 펼친 `IRQ_F2P[15:0]` 체크가 **둘 다** 보이게 | ✅ |
| `img/w7s1_05.png` | 그림 1-7 | `IRQ_F2P`를 켠 뒤의 PS 블록. `IRQ_F2P[0:0]`·`M_AXI_GP0` 표시(빨간 상자는 편집으로 추가) | ✅ |
| `img/w7s1_06.png` | 그림 1-8 | `axi_gpio_0` `Re-customize IP` → `Board` 탭과 창 맨 아래 `Enable Interrupt` 체크 | ✅ |
| `img/w7s1_07.png` | 그림 1-9 | `IP Configuration` 탭 — 채널 1/2 Width 4 | ✅ |
| `img/w7s1_08.png` | 그림 1-10 | Run Connection Automation — `S_AXI`만 체크 | ✅ |
| `img/w7s1_09.png` | 그림 1-11 | ILA를 붙이기 전 Block Design. `ip2intc_irpt` → `IRQ_F2P[0:0]` 선 | ✅ |
| `img/w7s1_10.png` | 그림 1-12 | `system_ila_0`까지 들어간 완성 Block Design | ✅ |
| `img/w7s1_11.png` | 그림 1-13 | Constraints에 `cora_z7_07s_week07.xdc` | ✅ (위쪽 경로 표시가 저장소 경로 — 학생은 `week7/W7_Interrupt/LAB01/xdc/`) |
| `img/w7s1_12.png` | 그림 1-14 | Export Hardware — XSA 이름과 저장 위치 | ⚠️ 다시 찍기 — 위치가 `…/week7/gpio_irq` (본문은 `…/week7/vivado_prj/gpio_irq`) |
| `img/w7s1_13.png` | 그림 1-15 | 탐색기 `impl_1` — `.bit`, `.ltx` | ⚠️ 다시 찍기 — 경로가 `week7/gpio_irq/…` (본문은 `week7/vivado_prj/gpio_irq/…`) |
| `img/w7s1_14.png` | 그림 1-16 | `xparameters.h`의 `AXI_GPIO_0` 정의 (`BASEADDR`, `INTERRUPT_PRESENT`, `INTERRUPTS`, `INTERRUPT_PARENT`) | ✅ |
| `img/w7s1_15.png` | 그림 1-17 | PuTTY — 스위치를 건드리기 전에는 아무 줄도 없다가, 움직이면 `count = …` 줄 | ✅ (직접 제어 코드로 보드 동작 확인) |

## 2교시 — [W7_S2_PS_Timer_Scheduler.md](W7_S2_PS_Timer_Scheduler.md) (제2장)

| 파일명 | 그림 | 담을 내용 | 상태 |
|---|---|---|---|
| `img/w7s2_01.png` | 그림 2-1 | PS `Clock Configuration` — CPU 650 MHz, `CPU Clock Ratio 6:2:1` | ✅ |
| `img/w7s2_02.png` | 그림 2-2 | `xparameters.h`의 `XPAR_CPU_CORE_CLOCK_FREQ_HZ 650000000` (`xtimer_config.h`는 본문 코드 블록으로 대신함) | ✅ |
| `img/w7s2_03.png` | 그림 2-4 | PuTTY — `t = 1 s`, `t = 2 s` … 가 1초에 한 줄씩 | ✅ (직접 제어 타이머 코드로 보드 동작 확인) |

(선택) 2.8절 실험 1(터미널은 `tick = …`로 쏟아지는데 LED 세 개가 멈춘 모습)과 실험 3(쏟아지는 줄 사이에 `t = N s`가 끼어드는 모습)을 찍어 주면 그림으로 넣는다.

## 3교시 — [W7_S3_ILA_Interrupt.md](W7_S3_ILA_Interrupt.md) (제3장)

| 파일명 | 그림 | 담을 내용 | 상태 |
|---|---|---|---|
| `img/w7s3_01.png` | 그림 3-1 | Hardware Manager — 칩 `Programmed`, `hw_ila_1`, `Probes file` 지정 | ✅ |
| `img/w7s3_02.png` | 그림 3-2 | Waveform 창에 `ila_sw4`, `ila_irq`, `slot_0` | ⚠️ 받은 화면은 `gpio_io_i_0_1`·`axi_gpio_0_gpio2_io_o`(LED) 프로브라 보류 — 하드웨어를 본문대로(`ila_sw4`·`ila_irq` Debug) 고친 뒤 다시 찍기 |
| `img/w7s3_03.png` | 그림 3-4 | **캡처 1** — 트리거 `ila_irq` R, 위치 128. `ila_irq` ↑ → `ARADDR 000` → `120` 읽기·쓰기 → `ila_irq` ↓ → `AWADDR 008`. 가능하면 ①→② 마커 | 📷 대기 |
| `img/w7s3_04.png` | 그림 3-5 | **캡처 2** — `Number of windows` 8. 창마다 `ila_irq` ↑, 이웃 창에서 `ila_sw4[0]`이 오락가락하는 모습 | 📷 대기 |
| `img/w7s3_05.png` | 그림 3-6 | **캡처 3** — ISR의 clear를 뺀 상태. `ila_irq`가 계속 1이고 `ARADDR 000` 읽기만 반복 | 📷 대기 |

## 캡처하면서 확인할 것

- 1.6절: `ip2intc_irpt` → `IRQ_F2P` 연결을 Vivado가 Connection Automation으로 제안하는지. 제안하면 본문에 한 줄 넣는다.
- 1.12절: **그림 1-17 실측에서는 바운스가 보이지 않았다**(변화 한 번에 `count` +1). 본문은 "바운스는 스위치에 따라 생길 수 있다"로 고쳤다. 3장 캡처 2(바운스 세기)와 2장 과제(20 ms 디바운스)가 바운스를 전제로 하므로, ILA로 실제 떨림이 있는지 먼저 확인한다. 거의 없으면 3장 캡처 2를 "스위치 한 번에 인터럽트 한 번"을 확인하는 실험으로 바꾼다.
- 2.7절: `t = N s` 줄이 초시계와 맞는지(타이머 325 MHz, `LOAD 324999`).
- 2.8절 실험 1: 본문 예측은 "터미널은 `tick = …`로 쏟아지고 main은 멈춘다(UART 버퍼가 차는 데 몇십 ms)". 실제 증상을 보고 고친다. `tick\n\r`(6자)로는 멈추지 않는다는 서술도 확인한다.
- 2.8절 실험 3: `t = N s` 줄이 출력 사이에 1초마다 끼어드는지.
- 3.2절: ① → ② 샘플 수(본문 표의 빈칸은 학생이 채우는 칸이지만, 대략의 값을 알아 두면 그림 3-3 위치를 실제와 맞출 수 있다). `IPISR` 읽기(`120`)가 실제로 보이는지.
- 3.3절: `Settings`의 `Number of windows`·`Window data depth`·`Trigger position in window` 이름과, 상태 표시에 창 번호가 나오는지. 창 하나가 2.5 µs(128샘플)라 바운스 간격보다 짧은지.
- 3.4절: clear가 없을 때 `ila_irq`가 계속 1이고 ISR이 반복되는지. BSP 설정은 레벨 트리거(`XPAR_AXI_GPIO_0_INTERRUPTS 0x401d`의 위 4비트 `4`)라서 반복되는 것이 맞다. 반복 간격(ISR 한 번의 시간)이 몇 샘플인지.

> **HEIC 주의.** 휴대폰 사진은 `.HEIC`로 저장되는 경우가 많고 GitHub·마크다운에서 보이지 않는다. 반드시 `.jpg`로 바꿔서 넣는다.
