# W5 LAB02 — `my_io` + System ILA 하드웨어 (Cora Z7-07S)

5주차 2교시(W5_S2) 실습 파일. 교재 본문은 [`../W5_S2_Vivado_ILA.md`](../W5_S2_Vivado_ILA.md)(제2장).

> **상태: 초안.** `build_lab05_reference.tcl`을 Vivado 2023.2 배치 모드로 처음부터 끝까지 실행해 Bitstream·`.ltx`·`.xsa` 생성까지 확인했다. GUI 화면 캡처와 실기기 동작은 아직 확인하지 않았다.

## 파일

```
LAB02/
├── xdc/cora_z7_07s_week05.xdc     # led4/led3/sw4/btn2 핀 배정 (4주차·중간고사와 같은 핀)
└── build_lab05_reference.tcl      # 1·2장 결과를 한 번에 만드는 스크립트
```

## 하드웨어

| 블록 | 역할 |
|---|---|
| `processing_system7_0` | PS. `M_AXI_GP0`은 Connection Automation이 켠다 |
| `ps7_0_axi_periph` | AXI Interconnect (자동 추가) |
| `rst_ps7_0_50M` | Processor System Reset (자동 추가) |
| `my_io_0` | 1장에서 만든 IP. 주소 **`0x43C0_0000`**, Range 64K |
| `system_ila_0` | `SLOT_0_AXI` 1개(본문: PS `M_AXI_GP0` 버스 / 스크립트: `my_io_0`의 `S00_AXI` 버스) + `probe0~3`(핀 4개), 깊이 1024, 클럭 `FCLK_CLK0` 50 MHz |

외부 포트는 `led4[3:0]`, `led3[2:0]`, `sw4[3:0]`, `btn2[1:0]`. Make External 직후에는 `_0`이 붙으므로 지운다.

## 핀

| 포트 | 핀 | 연결 |
|---|---|---|
| `led4[0..3]` | T14, V17, R17, N18 | shield 디지털 2, 4, 6, 8 |
| `sw4[0..3]` | U15, K18, J18, G15 | shield 디지털 10, 11, 12, 13 |
| `btn2[0..1]` | D20, D19 | BTN0, BTN1 |
| `led3[0..2]` | M15, L14, G14 | RGB LED1의 R, G, B |

## `build_lab05_reference.tcl`

```
vivado -mode batch -source build_lab05_reference.tcl
```

1. `my_io` 템플릿 생성 → [`../LAB01/hdl/`](../LAB01/hdl/)의 완성 Verilog로 교체 → Re-Package
2. `lab05` 프로젝트, Block Design(PS + `my_io_0`), 핀 4개 Make External과 이름 정리
3. AXI 버스와 핀 4개에 Debug → System ILA
4. XDC, Bitstream(+`.ltx`), `design_1_wrapper.xsa`

결과는 스크립트 옆 `build/`(수업 폴더 기준 `.../week5/W5_Custom_IP/LAB02/build/`)에 생긴다. 학생이 손으로 만든 `.../week5/vivado_prj/`는 건드리지 않는다. `.xsa`는 `build/vivado_prj/lab05/design_1_wrapper.xsa`, `.ltx`는 `build/vivado_prj/lab05/lab05.runs/impl_1/design_1_wrapper.ltx`.

**경로 주의.** 이 저장소는 한글이 섞인 경로(`...\문서\GitHub\...`)에 있어 Vivado가 실패할 수 있다. 스크립트는 자기 경로에 비ASCII 문자가 있으면 **`C:/vivado_w5`에 빌드**한다. 다른 위치를 쓰려면 `W5_BUILD_DIR` 환경변수를 지정한다.

쓰는 경우: 설계가 망가져 시간 안에 되돌리기 어려울 때, 조교가 결과를 검증할 때.

## 확인한 것 (배치 빌드)

- `my_io_0` 주소 `0x43C00000`, Range `0x00010000`
- 미배정 포트 0개, `write_bitstream Complete!`
- `.ltx` 생성: `lab05.runs/impl_1/design_1_wrapper.ltx`
- **본문과 다른 점:** 스크립트는 `my_io_0`의 `S00_AXI` 쪽 버스에 Debug를 붙이므로 AXI 주소 프로브가 4비트(`awaddr[3:0]`, `araddr[3:0]`)라 파형에 오프셋(`0`, `4`, `8`, `C`)만 보인다. 본문(2.5.1절)은 PS `M_AXI_GP0` 쪽에 붙이므로 32비트 주소(`43C00008` 등)가 보인다
- 핀 프로브는 Hardware Manager에서 `probe0_1`~`probe3_1` 이름으로 보인다. 스크립트 기준 순서는 `probe0=led3`, `probe1=led4`, `probe2=sw4`, `probe3=btn2`이지만, GUI로 만들면 Debug를 표시한 순서에 따라 달라질 수 있다
- 경고 `[PSU-1]`, `[PSU-2]`(DDR DQS 음수 지연)는 Cora 보드 프리셋에서 늘 나오는 것으로 무시한다

## 다음 LAB

[`../LAB03/README.md`](../LAB03/README.md) — Vitis로 읽고 쓰고, ILA로 버스 보기(제3장).
