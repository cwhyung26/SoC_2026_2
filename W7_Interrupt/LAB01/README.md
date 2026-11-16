# W7 LAB01 — AXI GPIO 인터럽트 하드웨어와 4비트 카운터 (Cora Z7-07S)

7주차 1교시(W7_S1) 실습 파일. 교재 본문은 [`../W7_S1_AXI_GPIO_Interrupt.md`](../W7_S1_AXI_GPIO_Interrupt.md)(제1장).

> **상태: 초안.** `build_lab07_reference.tcl`을 Vivado 2023.2 배치 모드로 처음부터 끝까지 실행해 Bitstream·`.ltx`·`.xsa` 생성까지 확인했다. 그 `.xsa`로 Vitis 2023.2 Platform과 `app_irq`를 만들어 빌드까지 확인했다. GUI 화면 캡처와 실기기 동작은 아직 확인하지 않았다.

## 파일

```
LAB01/
├── xdc/cora_z7_07s_week07.xdc     # sw4·led4 8핀 (4주차 shield와 같은 핀)
├── src/sw_irq_counter.c           # ISR은 기록 + clear, main이 LED·터미널 출력
└── build_lab07_reference.tcl      # 1장 하드웨어를 한 번에 만드는 스크립트
```

## 하드웨어 (`week7/vivado_prj/gpio_irq`)

| 블록 | 역할 |
|---|---|
| `processing_system7_0` | PS. `M_AXI_GP0` + `Fabric Interrupts`·`IRQ_F2P[0:0]` |
| `ps7_0_axi_periph` | AXI Interconnect (자동 추가) |
| `rst_ps7_0_50M` | Processor System Reset (자동 추가) |
| `axi_gpio_0` | 채널 1 입력 4비트(`sw4`), 채널 2 출력 4비트(`led4`), **Enable Interrupt**. 주소 **`0x4120_0000`**, Range 64K |
| `system_ila_0` | `SLOT_0_AXI` 1개(Interconnect `M00_AXI` ↔ `axi_gpio_0/S_AXI`, 주소 9비트) + `probe0` `ila_sw4`(4비트) + `probe1` `ila_irq`(1비트), 깊이 1024, 클럭 `FCLK_CLK0` 50 MHz |

- 바깥 포트는 **멤버 신호**(`gpio_io_i`, `gpio2_io_o`)를 Make External 해서 `sw4[3:0]`, `led4[3:0]`(접미사 없음).
- `ip2intc_irpt` → `IRQ_F2P`는 손으로 잇는다. 선 이름은 `ila_irq`, 스위치 선은 `ila_sw4`.

## 핀

| 포트 | 핀 |
|---|---|
| `sw4[0..3]` | U15, K18, J18, G15 |
| `led4[0..3]` | T14, V17, R17, N18 |

## 인터럽트 레지스터 (PG144)

| 오프셋 | 이름 | 역할 |
|---|---|---|
| `+0x11C` | `GIER` | bit 31 = IP 전체 인터럽트 출력 허용 (대문) |
| `+0x120` | `IPISR` | bit 0 = 채널 1 pending. **toggle-on-write** — 읽은 값을 그대로 다시 써서 지운다 |
| `+0x128` | `IPIER` | bit 0 = 채널 1 허용 (개별 문) |

## `sw_irq_counter.c`

5·6주차처럼 `#define`으로 레지스터 이름을 붙이고 `Xil_In32`/`Xil_Out32`로 직접 다룬다. 드라이버 함수는 GIC 등록(`XSetupInterruptSystem`) 하나뿐이다.

| 단계 | 코드 |
|---|---|
| ① 남은 pending 지우기 | `Xil_Out32(GPIO_IPISR, Xil_In32(GPIO_IPISR))` |
| ② ISR 등록 | `XSetupInterruptSystem(NULL, sw_isr, XPAR_AXI_GPIO_0_INTERRUPTS, XPAR_AXI_GPIO_0_INTERRUPT_PARENT, …)` |
| ③ 채널 1 허용 | `Xil_Out32(GPIO_IPIER, 0x1)` |
| ④ IP 출력 허용 | `Xil_Out32(GPIO_GIER, 0x80000000)` |
| ISR | `sw = Xil_In32(GPIO_DATA)`, `count` + 1, `flag = 1`, **pending 지우기** |
| main | `flag == 1`이면 `Xil_Out32(GPIO2_DATA, count)`, `xil_printf` |

방향 레지스터(`TRI`)는 쓰지 않는다. 채널 1은 `All Inputs`, 채널 2는 `All Outputs`로 하드웨어에서 고정했다.

스위치를 움직일 때만 PuTTY에 한 줄이 찍힌다. 한 번 움직였는데 `count`가 2 이상 뛰는 것은 "값이 바뀔 때마다" + 바운스 때문이다(본문 1.12절, 3장 캡처 2).

## Vitis

- 작업 공간 `.../week7/vitis_ws`, Platform `platform`, Application `app_irq`
- XSA: `.../week7/vivado_prj/gpio_irq/design_1_wrapper.xsa`
- `xparameters.h`: `XPAR_AXI_GPIO_0_BASEADDR 0x41200000`, `XPAR_AXI_GPIO_0_INTERRUPT_PRESENT 0x1`, `XPAR_AXI_GPIO_0_INTERRUPTS 0x401d`, `XPAR_AXI_GPIO_0_INTERRUPT_PARENT 0xf8f01000` — 코드는 주소와 마지막 두 값을 매크로로 쓴다
- 이 Platform 하나를 2장(`app_timer`)과 3장에서도 쓴다.

## `build_lab07_reference.tcl`

PowerShell이나 cmd에서 실행한다.

```
vivado -mode batch -source build_lab07_reference.tcl
```

1. `gpio_irq` 프로젝트, PS(`M_AXI_GP0`, `IRQ_F2P`), `axi_gpio_0`(4/4, Enable Interrupt)
2. Connection Automation(`S_AXI`만), 멤버 신호 Make External(`sw4`, `led4`), `ip2intc_irpt` → `IRQ_F2P`, 선 이름 `ila_sw4`·`ila_irq`
3. `axi_gpio_0/S_AXI` 버스, `ila_sw4`, `ila_irq`에 Debug → System ILA
4. XDC, Bitstream(+`.ltx`), `design_1_wrapper.xsa`

결과는 스크립트 옆 `build/`에 생긴다. 저장소처럼 한글 경로에 있으면 `C:/vivado_w7`에 빌드한다(`W7_BUILD_DIR`로 바꿀 수 있다). 학생이 만든 `.../week7/vivado_prj/`는 건드리지 않는다. 설계가 망가져 시간 안에 되돌리기 어려울 때만 쓴다.

## 확인한 것 (배치 빌드)

- `axi_gpio_0` 주소 `0x41200000`, Range `0x00010000`
- ILA: 슬롯 1, 프로브 2(`probe0` = `ila_sw4`, `probe1` = `ila_irq`), 깊이 1024. `.ltx`의 `ARADDR`/`AWADDR` 폭 9
- 미배정 포트 0개, `write_bitstream Complete!`, 타이밍 만족(WNS +12.0 ns)
- `.ltx`: `gpio_irq.runs/impl_1/design_1_wrapper.ltx` (같은 폴더의 `debug_nets.ltx`는 쓰지 않는다)
- 경고 `[PSU-1]`, `[PSU-2]`(DDR DQS 음수 지연)는 Cora 보드 프리셋에서 늘 나오는 것으로 무시한다
- Vitis: `xparameters.h`에 `XPAR_AXI_GPIO_0_INTERRUPT_PRESENT 0x1`, `XPAR_AXI_GPIO_0_INTERRUPTS 0x401d`(SPI 29 = GIC 61, 레벨 트리거). `app_irq` 빌드 성공(경고는 쓰지 않는 `ref` 인자 하나)

## 다음 LAB

[`../LAB02/README.md`](../LAB02/README.md) — 같은 하드웨어·같은 Platform에서 PS 타이머로 1 ms tick 스케줄러(제2장).
