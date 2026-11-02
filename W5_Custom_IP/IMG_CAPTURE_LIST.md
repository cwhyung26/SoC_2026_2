# 5주차 스크린샷 캡처 목록

본문은 아래 파일명을 이미 참조하도록 작성되어 있다. 캡처해서 `img/`에 이 이름으로 저장하고, 본문 캡션 끝의 **`📷 *캡처 대기*`** 표시를 지우면 된다.

빠진 그림 번호(1-1, 1-2, 1-10, 1-13, 1-15, 1-18, 2-1, 2-6, 2-11, 3-4~3-7, 3-12, 3-14, 3-26)는 개념 다이어그램이다. `img/w5_*.svg`로 이미 들어 있으므로 캡처하지 않는다. 캡처 1 파형(그림 3-15)은 그 앞의 기대 파형(그림 3-14)과 같은 순서로 보이는지 확인하며 찍는다.

4주차까지 여러 번 캡처한 화면(Block Automation, Create HDL Wrapper, I/O Planning, Export Hardware, Platform·Application 생성, 빌드 완료)은 캡처하지 않고 글로만 안내한다. **이번 주에 처음 나오는 화면만** 캡처한다.

## 1교시 — [W5_S1_Custom_IP_Create.md](W5_S1_Custom_IP_Create.md) (제1장)

| 파일명 | 그림 | 담을 내용 | 상태 |
|---|---|---|---|
| `img/w5s1_01.png` | 그림 1-3 | New Project — Project name `custom_ip`, location `…/week5/vivado_prj` | ✅ |
| `img/w5s1_02.png` | 그림 1-4 | `Tools → Create and Package New IP…` 메뉴 | ✅ |
| `img/w5s1_03.png` | 그림 1-5 | `Create a new AXI4 peripheral` 선택 | ✅ |
| `img/w5s1_04.png` | 그림 1-6 | `Peripheral Details`. Name `my_io`, Version 1.0, IP location `…/vivado_prj/ip_repo` | ✅ |
| `img/w5s1_05.png` | 그림 1-7 | `Add Interfaces`. `S00_AXI`, Lite, Slave, 32, Number of Registers 4 | ✅ |
| `img/w5s1_06.png` | 그림 1-8 | `Create Peripheral`의 Next Steps에서 `Edit IP` 선택 | ✅ |
| `img/w5s1_07.png` | 그림 1-9 | `custom_ip` 창 위에 열린 `edit_my_io_v1_0` 창 | ✅ |
| `img/w5s1_08.png` | 그림 1-11 | Sources 계층과 열린 `my_io_v1_0_S00_AXI.v` | ✅ |
| `img/w5s1_10.png` | 그림 1-12 | `slv_reg0~3` 선언(약 107줄) | ✅ |
| `img/w5s1_11.png` | 그림 1-14 | `reg_data_out`의 `case`(약 372줄) | ✅ |
| `img/w5s1_09.png` | 그림 1-16 | `Users to add ports here` ~ `User ports ends`(약 17~19줄) | ✅ |
| `img/w5s1_12.png` | 그림 1-17 | `Add user logic here` ~ `User logic ends`(약 400~402줄) | ✅ |
| `img/w5s1_19.png` | 그림 1-19 | Verilog 수정 후 `Open Elaborated Design`의 Schematic. 바깥 포트 4개가 안쪽 인스턴스까지 이어진 모습 | 📷 대기 |
| `img/w5s1_13.png` | 그림 1-20 | Verilog 수정 후 연필 표시가 붙은 `Packaging Steps` | ✅ |
| `img/w5s1_20.png` | 그림 1-21 | `Ports and Interfaces`. Merge 후 `led4`, `led3`, `sw4`, `btn2`가 목록에 있는 모습 | 📷 대기 |
| `img/w5s1_14.png` | 그림 1-22 | `Review and Package` → `Re-Package IP` | ✅ |
| `img/w5s1_15.png` | 그림 1-23 | Close Project 질문 → `Yes` | ✅ |
| `img/w5s1_16.png` | 그림 1-24 | `Settings → IP → Repository` — `my_io_1_0 (Project)` | ✅ |
| `img/w5s1_17.png` | 그림 1-25 | `+` → `vivado_prj/ip_repo` 선택 | ✅ |
| `img/w5s1_18.png` | 그림 1-26 | IP Catalog 검색 `my` → `User Repository → AXI Peripheral → my_io_v1.0` | ✅ |

## 2교시 — [W5_S2_Vivado_ILA.md](W5_S2_Vivado_ILA.md) (제2장)

| 파일명 | 그림 | 담을 내용 | 상태 |
|---|---|---|---|
| `img/w5s2_01.png` | 그림 2-2 | Add IP 검색 `my` → `my_io_v1.0`, 들어온 `my_io_0` 블록 | ✅ |
| `img/w5s2_02.png` | 그림 2-3 | Run Connection Automation — `my_io_0/S00_AXI` 하나 | ✅ |
| `img/w5s2_03.png` | 그림 2-4 | External Port Properties에서 `led4_0` → `led4` | ✅ |
| `img/w5s2_04.png` | 그림 2-5 | Address Editor. `my_io_0/S00_AXI` = `0x43C0_0000`, Range 64K | ✅ |
| `img/w5s2_05.png` | 그림 2-7 | `M_AXI_GP0` 버스와 핀 선에 Debug(벌레) 표시 | ✅ |
| `img/w5s2_06.png` | 그림 2-8 | Debug용 Run Connection Automation. 대상 5개, Source Clock `FCLK_CLK0` | ✅ |
| `img/w5s2_07.png` | 그림 2-9 | 완성된 Block Design 전체(`system_ila_0` 포함) | ✅ |
| `img/w5s2_08.png` | 그림 2-10 | System Net 이름을 `ila_btn2`로 | ✅ |
| `img/w5s2_09.png` | 그림 2-12 | Constraints에 추가된 `cora_z7_07s_week05.xdc` | ✅ |
| `img/w5s2_10.png` | 그림 2-13 | Export Hardware — Export to `.../vivado_prj/custom_ip` | ✅ |
| `img/w5s2_11.png` | 그림 2-14 | 탐색기 `week5` — `vitis_ws`, `vivado_prj`, `W5_Custom_IP` | ✅ |
| `img/w5s2_12.png` | 그림 2-15 | 탐색기 `vivado_prj/ip_repo/my_io_1_0` | ✅ |
| `img/w5s2_13.png` | 그림 2-16 | 탐색기 `custom_ip.runs/impl_1` — `.bit`, `.ltx` | ✅ |

## 3교시 — [W5_S3_Vitis_ILA.md](W5_S3_Vitis_ILA.md) (제3장)

| 파일명 | 그림 | 담을 내용 | 상태 |
|---|---|---|---|
| `img/w5s3_01.png` | 그림 3-1 | Open Workspace → `week5/vitis_ws` | ✅ |
| `img/w5s3_02.png` | 그림 3-2 | `src` Import → `W5_Custom_IP/LAB03/src/my_io_test.c` | ✅ |
| `img/w5s3_03.png` | 그림 3-3 | `xparameters.h`의 `XPAR_MY_IO_0_BASEADDR` 줄 | ✅ |
| `img/w5s3_04.png` | 그림 3-8 | `launch.json` — Initialization file `ps7_init.tcl` | ✅ |
| `img/w5s3_05.png` | 그림 3-9 | PuTTY `sw = 12 btn = 1` | ✅ |
| `img/w5s3_06.png` | 그림 3-10 | `custom_ip`에서 Open Hardware Manager → Auto Connect | ✅ |
| `img/w5s3_07.png` | 그림 3-11 | Hardware Manager — `.bit`·`.ltx`, `hw_ila_1`, Waveform | ✅ |
| `img/w5s3_08.png` | 그림 3-13 | Trigger Setup `ARVALID == R` | ✅ |
| `img/w5s3_09.png` | 그림 3-15 | **캡처 1** 한 바퀴(읽기 2, 쓰기 2) | ✅ |
| `img/w5s3_10.png` | 그림 3-16 | 캡처 1 확대 — 읽기 두 번 | ✅ |
| `img/w5s3_11.png` | 그림 3-17 | `WVALID == 1` 트리거 — 쓰기 두 번 | ✅ |
| `img/w5s3_12.png` | 그림 3-18 | Debug 보기 — Stop으로 실행 멈추기 | ✅ |
| `img/w5s3_13.png` | 그림 3-19 | Debug 시작 — `main`에서 PAUSED ON BREAKPOINT | ✅ |
| `img/w5s3_14.png` | 그림 3-20 | Step Over 후 21줄, PuTTY `my io start` | ✅ |
| `img/w5s3_19.png` | 그림 3-21 | **캡처 2** 파형. `Xil_Out32(REG_LED4, sw)` Step Over 한 번에 잡힌 쓰기 하나(`AWADDR=43c00000`)와 `led4` 변화. 트리거 `AWVALID = 1`. **스위치를 바꾼 뒤** Step Over 해야 `led4`가 바뀌는 모습이 보인다 | 📷 대기 |
| `img/w5s3_15.png` | 그림 3-22 | Vivado 시작 화면 `Tasks → Open Hardware Manager` | ✅ |
| `img/w5s3_16.png` | 그림 3-23 | 프로젝트 없는 Hardware Manager — Auto Connect | ✅ |
| `img/w5s3_17.png` | 그림 3-24 | Specify Probes File — `design_1_wrapper.ltx` | ✅ |
| `img/w5s3_18.png` | 그림 3-25 | `.ltx` 지정 후 Waveform | ✅ |

## 캡처하면서 확인할 것

- ~~Hardware Manager에서 핀 프로브가 선 이름으로 보이는지~~ → 확인함. `ila_btn2` 등 선 이름 그대로 보인다.
- ~~트리거 신호 이름(`ARVALID` 등)이 본문과 같은지~~ → 확인함. `slot_0 : processing_system7_0_M_AXI_GP0 : ARVALID`.
- ~~캡처 1의 네 동작이 한 화면에 들어오는지~~ → 확인함. 약 60 클럭(샘플 510~570) 안에 모두 들어온다. Trigger position 기본값(512)으로 충분하다.
- 캡처 2에서 Debug 재시작 후 `Refresh Device`만으로 ILA가 다시 잡히는지.

> **HEIC 주의.** 휴대폰 사진은 `.HEIC`로 저장되는 경우가 많고 GitHub·마크다운에서 보이지 않는다. 반드시 `.jpg`로 바꿔서 넣는다.
