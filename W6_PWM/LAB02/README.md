# W6 LAB02 — `my_pwm` + System ILA 하드웨어 (Cora Z7-07S)

6주차 2교시(W6_S2) 실습 파일. 교재 본문은 [`../W6_S2_Vivado_ILA.md`](../W6_S2_Vivado_ILA.md)(제2장).

> **상태: 초안.** `build_lab06_reference.tcl`을 Vivado 2023.2 배치 모드로 처음부터 끝까지 실행해 Bitstream·`.ltx`·`.xsa` 생성까지 확인했다. GUI 화면 캡처와 실기기 동작은 아직 확인하지 않았다.

## 파일

```
LAB02/
├── xdc/cora_z7_07s_week06.xdc     # led4 4핀만 (4·5주차와 같은 핀)
└── build_lab06_reference.tcl      # 1·2장 결과를 한 번에 만드는 스크립트
```

## 하드웨어

| 블록 | 역할 |
|---|---|
| `processing_system7_0` | PS. `M_AXI_GP0`은 Connection Automation이 켠다 |
| `ps7_0_axi_periph` | AXI Interconnect (자동 추가) |
| `rst_ps7_0_50M` | Processor System Reset (자동 추가) |
| `my_pwm_0` | 1장에서 만든 IP. 주소 **`0x43C0_0000`**, Range 64K |
| `system_ila_0` | `SLOT_0_AXI` 1개(Interconnect `M00_AXI` ↔ `my_pwm_0/S00_AXI` 버스, 주소 4비트) + `probe0`(`ila_led4`, 4비트), 깊이 1024, 클럭 `FCLK_CLK0` 50 MHz |

외부 포트는 `led4[3:0]` 하나. Make External 직후 `led4_0`이므로 `led4`로 고친다. 선(net) 이름은 `ila_led4`로 고친다.

## 핀

| 포트 | 핀 | 연결 |
|---|---|---|
| `led4[0..3]` | T14, V17, R17, N18 | shield 디지털 2, 4, 6, 8 |

## `build_lab06_reference.tcl`

PowerShell이나 cmd에서 실행한다(Git Bash에서 실행하면 `create_bd_design`이 `bd::utils::dbg` 오류로 실패한 적이 있다).

```
vivado -mode batch -source build_lab06_reference.tcl
```

1. `my_pwm` 템플릿 생성 → [`../LAB01/hdl/`](../LAB01/hdl/)의 완성 Verilog로 교체 → Re-Package
2. `custom_pwm` 프로젝트, Block Design(PS + `my_pwm_0`), `led4` Make External, 선 이름 `ila_led4`
3. `my_pwm_0/S00_AXI` 버스와 `ila_led4`에 Debug → System ILA (본문 2.5절과 같다)
4. XDC, Bitstream(+`.ltx`), `design_1_wrapper.xsa`

결과는 스크립트 옆 `build/`(수업 폴더 기준 `.../week6/W6_PWM/LAB02/build/`)에 생긴다. 학생이 만든 `.../week6/vivado_prj/`는 건드리지 않는다. 저장소처럼 한글 경로에 있으면 `C:/vivado_w6`에 빌드한다(`W6_BUILD_DIR`로 바꿀 수 있다).

## 확인한 것 (배치 빌드)

- `my_pwm_0` 주소 `0x43C00000`, Range `0x00010000`
- ILA: 슬롯 1, 프로브 1, 깊이 1024
- 미배정 포트 0개, `write_bitstream Complete!`, 타이밍 만족(WNS +10.3 ns)
- `.ltx`: `custom_pwm.runs/impl_1/design_1_wrapper.ltx` (같은 폴더의 `debug_nets.ltx`는 쓰지 않는다)
- 경고 `[PSU-1]`, `[PSU-2]`(DDR DQS 음수 지연)는 Cora 보드 프리셋에서 늘 나오는 것으로 무시한다

## 다음 LAB

[`../LAB03/README.md`](../LAB03/README.md) — Vitis로 밝기 바꾸기, ILA로 PWM 보기(제3장).
