# W5 LAB01 — AXI GPIO 인터럽트와 4비트 카운터 (Cora Z7-07S)

5주차 1교시(W5_S1) 실습 파일. 교재 본문은 [`../W5_S1_AXI_GPIO_Interrupt.md`](../W5_S1_AXI_GPIO_Interrupt.md)(제1장).

> **상태: 초안, 실기기 미검증.** 본문 캡션의 `📷 *캡처 대기*`가 스크린샷 자리다. 캡처 목록은 [`../IMG_CAPTURE_LIST.md`](../IMG_CAPTURE_LIST.md)에 있다(5주차는 7장만 찍는다 — 1~4주차에서 프로젝트 생성 화면을 충분히 캡처했으므로 **새로운 것과 결과만** 남겼다).

## 프로젝트를 새로 만든다

4주차 프로젝트를 복사해서 이어 갈 수도 있지만, **Vivado 조작을 한 번 더 익히는 것이 이번 주 연습의 목적**이므로 빈 프로젝트에서 시작한다. 프로젝트 이름은 **`lab03`**(이 과목의 세 번째 Vivado 프로젝트, 4주차에 `lab01`·`lab02b`를 만들었다).

## 이번 LAB의 하드웨어 — AXI GPIO 하나, 2채널

4주차 2교시에서 shield에 배선한 **스위치 4개·LED 4개를 그대로 쓴다.** 배선과 핀 배정이 바뀌지 않으므로 XDC도 같은 내용이다.

```text
AXI GPIO 하나 (axi_gpio_0)
  채널 1 (입력  4비트) = sw4[3:0]   ← shield 스위치 4개
  채널 2 (출력  4비트) = led4[3:0]  → shield LED 4개
  + Enable Interrupt → ip2intc_irpt → PS의 IRQ_F2P[0:0]
베이스 주소: 0x4120_0000 (슬레이브가 하나뿐 → Address Editor에 한 줄)
```

4주차와 달라지는 점은 두 가지다. **AXI GPIO가 1개**(4주차는 보드용 + shield용 2개였다 — 보드 버튼 `btn`과 RGB LED `led0`는 5주차에 쓰지 않으므로 넣지 않는다), 그리고 거기에 **인터럽트 출력이 붙는다.**

## 이 하드웨어(`lab03`)는 LAB02와 공유한다

2교시의 PS Private Timer는 APU 코어 안에 있어서 Vivado에서 켤 것이 없다. 그래서 **이번 LAB에서 만든 `.xsa`와 `w5_platform` 하나로 5주차 실습 두 개를 모두 진행한다.** 4주차에 LAB마다 Platform을 새로 만들었던 것과 대비되는 지점이며, 본문에서 그 이유를 설명한다.

```
LAB01/
├── src/
│   └── sw_irq_counter.c              # ISR에서 4비트 카운터, main에서 LED·터미널 출력
├── xdc/
│   └── cora_z7_07s_week05.xdc        # 수업 중 Import하는 파일 (shield 8핀)
└── build_lab03_reference.tcl         # 검증·복구용 (수업에서는 쓰지 않는다)
```

## Vivado에서 하는 일 (본문 1.3~1.7절)

| 절 | 내용 |
|---|---|
| 1.3 | 새 프로젝트 `lab03` → Cora Z7-07S → Block Design → ZYNQ7 PS → `Run Block Automation` |
| 1.4 | PS의 **`M AXI GP0`** 켜기 |
| 1.5 | AXI GPIO 추가(2채널 4/4) + **`Enable Interrupt`** → `Run Connection Automation`은 **`S_AXI`만** → 멤버 신호 Make External(`sw4`/`led4`) |
| 1.6 | PS의 **`Fabric Interrupts` → `IRQ_F2P`** 켜고 `ip2intc_irpt`를 **손으로 연결** |
| 1.7 | Validate → HDL Wrapper → **XDC Import** → Synthesis → Bitstream → Export(`Include bitstream`) |

## 핵심 포인트

- **인터럽트 경로**: `IPISR` pending → `ip2intc_irpt` → `IRQ_F2P` → GIC → CPU0 → ISR. 이 경로에서 **인터럽트 선은 "변했다"는 사실만 전달**하고, 실제 값은 ISR이 4주차와 똑같은 AXI4-Lite 경로로 읽는다.
- **`Enable Interrupt`는 하드웨어를 바꾼다.** 체크하면 `GIER`/`IPIER`/`IPISR` 레지스터와 변화 감지 회로가 합성되어 들어간다. 그래서 비트스트림·XSA를 반드시 새로 만들어야 하고, 반영 여부는 `xparameters.h`의 `XPAR_AXI_GPIO_0_INTERRUPT_PRESENT`가 `0x1`인지로 확인한다(4주차 플랫폼에서는 `0x0`이다). **코드를 쓰기 전에 여기서 확인하는 것이 가장 빠른 점검이다.**
- **인터럽트 레지스터**(Xilinx PG144, 보드 무관 고정): `GIER`(+0x11C, IP 전체 허용) / `IPISR`(+0x120, pending·clear) / `IPIER`(+0x128, 채널별 허용).
- **초기화 순서**: pending clear → ISR 등록(`XSetupInterruptSystem`) → 채널 enable(`IPIER`) → global enable(`GIER`). **받을 준비를 먼저 하고 문을 연다** — 순서를 뒤집으면 ISR이 등록되기 전에 인터럽트가 도착할 수 있다.
- **pending clear는 필수.** `XGpio_InterruptClear()`를 빠뜨리면 ISR이 무한 반복되고 main으로 돌아오지 못한다. 본문 과제 4에서 일부러 재현해 본다.
- **인터럽트는 채널 단위, 그리고 "변할 때마다"** 발생한다. `sw4` 중 어느 비트가 바뀌어도 pending은 `XGPIO_IR_CH1_MASK` 하나이고, 올릴 때·내릴 때 각각 이벤트가 된다. 여기에 접점 바운스가 겹쳐 **카운터가 한 번에 2~4씩 뛴다** — 고장이 아니라 관찰 대상이며, 과제 1·2가 이걸 다룬다.
- **`XGpio_InterruptGetStatus()`를 생략했다.** 채널 1 하나만 인터럽트로 허용했으므로 ISR이 불렸다는 것 자체가 원인을 말해 준다. 여러 원인을 한 ISR이 처리할 때 비로소 필요해지는 코드다.
- **ISR은 짧게, 일은 main이.** ISR은 값 기록 3줄 + clear 1줄로 끝내고, LED 출력과 `xil_printf`는 main이 한다. ISR과 main이 공유하는 변수에는 `volatile`을 빠짐없이 붙인다.
- **인터럽트 번호를 손으로 쓰지 않는다.** `XGpio_LookupConfig()`가 돌려주는 `IntrId`/`IntrParent`를 `XSetupInterruptSystem()`에 넘긴다. Vivado 설계에서 생성된 값이므로 설계가 바뀌면 자동으로 따라온다.

## `build_lab03_reference.tcl` — 수업용이 아니라 검증·복구용

수업에서는 위 표대로 **손으로 만드는 것이 연습**이다. 이 스크립트는 같은 하드웨어를 빈 프로젝트에서 한 번에 만들어 bitstream과 `.xsa`까지 뽑는다.

1. **검증** — 이 설계가 Vivado 2023.2에서 실제로 합성·구현·XSA export까지 통과하는지 확인한다.
2. **복구** — 설계가 망가졌는데 수업 시간에 되돌릴 여유가 없을 때 쓴다.

```
cd <이 LAB01 폴더>
vivado -mode batch -source build_lab03_reference.tcl
```

**경로 주의.** 이 저장소는 `...\문서\GitHub\...` 처럼 한글이 섞인 경로에 있는데, Vivado는 비ASCII·긴 경로에서 실패할 수 있다. 그래서 스크립트가 **자신의 경로에 비ASCII 문자가 있으면 자동으로 `C:/vivado_w5`에 빌드**하고 그 이유를 출력한다. 다른 위치를 쓰려면 `W5_BUILD_DIR` 환경변수를 지정한다.

스크립트 설정이 본문의 GUI 조작과 1:1로 대응한다.

| 본문의 GUI 조작 | 스크립트의 설정 |
|---|---|
| `M AXI GP0 interface` 체크 (1.4절) | `CONFIG.PCW_USE_M_AXI_GP0 {1}` |
| `Enable Interrupt` 체크 (1.5절) | `CONFIG.C_INTERRUPT_PRESENT {1}` |
| 채널 1 입력 4비트 / 채널 2 출력 4비트 | `C_ALL_INPUTS`+`C_GPIO_WIDTH {4}` / `C_ALL_OUTPUTS_2`+`C_GPIO2_WIDTH {4}` |
| 멤버 신호 Make External (1.5절) | `make_bd_pins_external -name sw4 / led4` |
| `Fabric Interrupts` + `IRQ_F2P` 체크 (1.6절) | `CONFIG.PCW_USE_FABRIC_INTERRUPT {1}`, `CONFIG.PCW_IRQ_F2P_INTR {1}` |
| `ip2intc_irpt` → `IRQ_F2P` 선 연결 (1.6절) | `connect_bd_net` 한 줄 |

스크립트는 합성 전에 **실제 top 포트 목록과 배정된 주소를 출력**한다. XDC의 포트 이름이 어긋나면 합성에서 "no ports matched"가 나므로 그때 여기를 먼저 본다.

## 검증 필요

- **`Enable Interrupt` 체크박스의 정확한 위치와 라벨.** `IP Configuration` 탭 안에 있는 것으로 작성했으나, 실기기 화면에서 확인해 본문 그림 1-3과 문장을 맞춘다.
- **`ip2intc_irpt` → `IRQ_F2P[0:0]` 연결 방법.** 손으로 선을 끄는 것으로 작성했다. Vivado가 `Run Connection Automation`으로 이 연결을 제안하는지 확인하고, 제안한다면 본문에 추가한다.
- **`Fabric Interrupts` 체크 후 포트 표기**가 `IRQ_F2P[0:0]`인지(소스 1개) 확인한다.
- **TCL 실행 확인.** `tclsh`로 Tcl 문법은 통과했지만 **Vivado에서 실제로 돌려보지 않았다.** 특히 `make_bd_pins_external`로 멤버 신호를 내보내는 부분과 `apply_bd_automation`의 axi4 규칙을 확인해야 한다.
- **카운터 증가량.** shield 스위치가 슬라이드 방식이므로 1회 조작에 이벤트 2개를 예상했다. 실제 증가 패턴과 바운스 정도를 로그로 확인해 본문 "카운터는 예상대로 오르지 않는다"의 서술을 실측에 맞춘다.

## 다음 LAB

`LAB02`(W5_S2): **같은 하드웨어·같은 Platform**에 Application만 추가해, Cortex-A9 Private Timer로 1 ms tick을 만들고 잡 스케줄러를 구성한다. [`../LAB02/README.md`](../LAB02/README.md).
