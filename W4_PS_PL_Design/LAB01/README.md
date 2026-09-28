# W4 LAB01 — AXI GPIO #1, 레지스터 직접 접근 (Cora Z7-07S)

4주차 1교시(W4_S1) 실습 파일. 교재 본문은 [`../W4_S1_AXI_GPIO_Register.md`](../W4_S1_AXI_GPIO_Register.md)(제7장).

> **상태: 초안, 실기기 미검증.** 본문의 `📷 [촬영]` 표시가 스크린샷 자리이며, 실습을 진행하면서 캡처를 넣고 필요하면 절차를 바로잡는다.

## 이번 LAB의 설계

PL에 처음으로 진짜 IP(AXI GPIO)가 들어간다. PS의 `M AXI GP0`을 켜고, AXI GPIO 1개를 듀얼 채널(채널1=입력 2비트, 채널2=출력 3비트)로 구성해 Cora Z7-07S의 `BTN0`/`BTN1`과 RGB LED0을 직접 연결한다.

```
LAB01/
├── xdc/
│   └── cora_z7_07s_week04_lab01.xdc   # 참고용 답안. 포트 이름은 실습 중 재확인
├── src/
│   └── btn_led_reg.c                   # Xil_Out32/Xil_In32로 AXI GPIO 레지스터 직접 접근
└── build_lab01_reference.tcl           # 완성 실패 시 참고용 (아래 설명)
```

## `build_lab01_reference.tcl` — 완성 실패한 학생 참고용

수업에서는 7.2~7.5절을 **손으로 만드는 것이 연습**이다. 이 스크립트는 같은 하드웨어를 빈 프로젝트에서 한 번에 만들어 bitstream과 `.xsa`까지 뽑는다. 쓰는 상황은 세 가지다.

1. 시간 안에 완성하지 못했거나 프로젝트가 망가진 학생이 **다음 진도를 따라갈 수 있게** 할 때.
2. **LAB02가 `lab01` 복사로 시작하므로**(8.1절), `lab01`이 없으면 2교시를 아예 진행할 수 없다. 이 스크립트로 `lab01`을 만든 뒤 `File → Save Project As…`로 `lab02b`를 만들면 된다.
3. 조교·교수가 설계가 여전히 빌드되는지 확인할 때.

```
cd <이 LAB01 폴더>
vivado -mode batch -source build_lab01_reference.tcl
```

**경로 주의.** 이 저장소는 `...\문서\GitHub\...` 처럼 한글이 섞인 경로에 있는데, Vivado는 비ASCII·긴 경로에서 실패할 수 있다. 스크립트가 **자신의 경로에 비ASCII 문자가 있으면 자동으로 `C:/vivado_w4`에 빌드**하고 이유를 출력한다. 다른 위치를 쓰려면 `W4_BUILD_DIR` 환경변수를 지정한다.

스크립트 설정이 본문의 GUI 조작과 1:1로 대응한다.

| 본문의 GUI 조작 | 스크립트의 설정 |
|---|---|
| `Run Block Automation`(Apply Board Preset) — 7.2절 | `apply_bd_automation ... processing_system7` |
| `M AXI GP0 interface` 체크 — 7.2절 | `CONFIG.PCW_USE_M_AXI_GP0 {1}` |
| 채널1 입력 2비트 / 채널2 출력 3비트 — 7.3.2절 | `C_ALL_INPUTS`+`C_GPIO_WIDTH {2}` / `C_ALL_OUTPUTS_2`+`C_GPIO2_WIDTH {3}` |
| `Run Connection Automation`에서 `S_AXI`만 — 7.3.3절 | `apply_bd_automation ... axi4`, `intc_ip {New AXI Interconnect}` |
| 인터페이스 Make External(`btn`/`led0`) — 7.3.4절 | `make_bd_intf_pins_external -name btn / led0` |
| I/O Planning에서 핀 5개 배정 → `my.xdc` 저장 — 7.5절 | 스크립트가 같은 내용의 `my.xdc`를 직접 생성 |
| `Generate Bitstream` → `Export Hardware`(Include bitstream) | `launch_runs ... write_bitstream`, `write_hw_platform -fixed -include_bit` |

> **왜 `xdc/cora_z7_07s_week04_lab01.xdc`를 쓰지 않고 `my.xdc`를 새로 만드는가.** 저장소의 그 파일은 포트 이름이 **`btn[0]`·`led0[0]`** 로 적혀 있는데, 7.3.4절처럼 **인터페이스**를 Make External 하면 실제 top 포트는 **`btn_tri_i[1:0]`·`led0_tri_o[2:0]`** 가 된다(그림 7-11에서 확인한 이름). 그 파일을 그대로 쓰면 합성에서 "no ports matched"가 난다. 그래서 스크립트는 올바른 이름으로 `my.xdc`를 직접 써 넣는다 — 파일 이름을 `my.xdc`로 맞춘 것은 7.5절에서 학생이 손으로 저장하는 이름과 같게 하려는 것이다. 핀 배정 값(D20/D19, N15/G17/L15)은 두 파일이 동일하다.

스크립트는 합성 전에 **실제 top 포트 목록과 배정된 주소를 출력**한다. `btn_led_reg.c`의 `AXI_GPIO_BASEADDR`(`0x41200000`)와 출력된 주소가 같은지 확인하는 데 쓴다.

> **검증 상태**: `tclsh`로 Tcl 문법은 통과했으나 **Vivado에서 실제로 실행해 보지 않았다.** 특히 `apply_bd_automation`의 두 규칙과 `make_bd_intf_pins_external` 결과 이름을 실행으로 확인해야 한다.

## 핵심 포인트

- **AXI4-Lite**: PS(마스터)가 PL의 IP(슬레이브)를 주소로 읽고 쓰는 버스. 3주차의 "PS 자신의 GPIO 레지스터를 직접 만지던 것"과 원리는 같고, 이번엔 그 레지스터가 PL 안에 있다.
- **AXI GPIO 레지스터 맵** (Xilinx PG144, 보드 무관 고정값): `GPIO_DATA`(+0x0)/`GPIO_TRI`(+0x4, 채널1), `GPIO2_DATA`(+0x8)/`GPIO2_TRI`(+0xC, 채널2).
- **TRI 레지스터는 1=입력.** 3주차 PS GPIO의 `DIRM`(1=출력)과 정반대이니 주의.
- 베이스 주소(`0x41200000` 예시)는 **Vivado Address Editor에서 실제 값을 확인**해 코드에 반영해야 한다 — 프로젝트마다 다를 수 있다.

## 아직 안 한 것 / 검증 필요

- ~~AXI GPIO Re-customize 창의 탭 구성~~ → 실기기 캡처로 확인 완료: 별도 탭이 아니라 `IP Configuration` 탭 한 화면 안에 `GPIO`(채널1)/`GPIO 2`(채널2) 두 구역이 위아래로 있다.
- `Make External`로 만든 포트(`btn`, `led0`)가 합성 후 정확히 어떤 이름이 되는지(예: `btn_tri_i[1:0]`, `led0_tri_o[2:0]` 등) 확인해 XDC·본문에 반영한다.
- `AXI_GPIO_BASEADDR`(`0x41200000`)는 전형적인 기본값 예시이며, 실제 Address Editor 값으로 확인·수정해야 한다.

## 다음 LAB

`LAB02`(W4_S2): 이 프로젝트를 이어서 열어 AXI GPIO #2(shield LED·스위치)를 추가하고, 같은 동작을 `XGpio` 드라이버로 다시 짠다. [`../LAB02/README.md`](../LAB02/README.md).
