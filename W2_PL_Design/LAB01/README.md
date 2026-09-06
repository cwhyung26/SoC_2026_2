# W2 LAB01 — PL 카운터 + Clocking Wizard + System ILA (Cora Z7-07S)

2주차 실습 파일 모음. 교재 본문은 [`../W2_S1_RTL_Simulation.md`](../W2_S1_RTL_Simulation.md)(제3장)와 [`../W2_S2_BlockDesign_ILA_Hardware.md`](../W2_S2_BlockDesign_ILA_Hardware.md)(제4장).

Cora Z7-07S에는 쓸 만한 LED가 없으므로 이 설계에는 **데이터 출력 핀이 없다.** 카운터 신호(`count`, `tick`, `div_count`)는 System ILA로만 관찰하고, 하드웨어 확인은 Hardware Manager의 ILA 파형으로 한다.

이 실습의 Block Design은 **의도적으로 단순하게** 만든다. Processor System Reset IP나 `locked` 처리를 넣지 않고 버튼 하나를 리셋에 직결한다. 그 결과 `Validate Design`에서 `[BD 41-1348]` critical warning이 하나 나오는데, 이는 예상된 것이며 교재 3.7절에서 설명한다.

## 구성

```
LAB01/
├── rtl/
│   ├── counter_n.v          # 파라미터 N비트 카운터 (지난 학기 재사용)
│   └── pl_counter.v         # 100 MHz → 10 Hz clock-enable 분주 래퍼, counter_n 인스턴스화
│                            #   count / tick / div_count 를 ILA 관찰용으로 노출 (핀 아님)
├── tb/
│   └── tb_pl_counter.v      # CLK_HZ/STEP_HZ 축소 오버라이드로 빠르게 관찰하는 테스트벤치
├── xdc/
│   └── cora_z7_07s_week02.xdc  # 참고용. 학생은 W2_S2에서 GUI로 my.xdc를 만든다.
│                               #   내용: reset_rtl → 핀 D20 (LVCMOS33) 하나뿐.
│                               #   sys_clock(H16)은 BD의 Connection Automation이 보드 정의로 자동 처리.
├── create_project.tcl      # 프로젝트 생성 + RTL/TB 추가까지만 (제약·Block Design은 수동)
└── build_bd_reference.tcl  # 단순화된 BD+ILA를 bitstream까지 재현하는 강의자 검증용 스크립트
```

## 설계 개요 (교재 제3~4장)

외부 포트는 입력 2개뿐이다.

```
sys_clock  (125 MHz, 핀 H16) ─→ clk_wiz_0/clk_in1        [Connection Automation → 보드 sys_clock]
clk_wiz_0/clk_out1 (100 MHz) ─┬→ pl_counter_0/clk
                              └→ system_ila_0/clk
reset_rtl  (버튼 BTN0, 핀 D20, active-high) ─┬→ clk_wiz_0/reset
                                             └→ pl_counter_0/rst
pl_counter_0/{count, div_count, tick} ─ 우클릭 Debug ─→ System ILA probe0..2
clk_wiz_0/locked : 사용 안 함 (열어 둠)
```

IP 설정 요점:

- **Clocking Wizard**: Primary Clock Source = Single ended clock capable pin, Input 125 MHz, Output `clk_out1` 100 MHz, Reset Type **Active High**. `locked`는 미사용.
- **pl_counter**: `Add Module…`로 Module Reference 추가.
- **System ILA**: net(`count`/`div_count`/`tick`) 우클릭 → Debug → Run Connection Automation, Clock Source `clk_wiz_0/clk_out1`. Sample Data Depth **2048**, **Capture Control** 체크(BASIC 캡처 모드용). probe0=`count`(4), probe1=`div_count`(24), probe2=`tick`(1).

핀 배정과 XDC(제4장):

- `Open Synthesized Design` → `Layout → I/O Planning` → `reset_rtl` 행에 Package Pin `D20`, I/O Std `LVCMOS33`.
- `Ctrl+S` → `Save Constraints` → 새 파일 `my.xdc`. System ILA가 있으므로 Vivado가 `dbg_hub` 관련 줄을 자동으로 덧붙인다(수정·삭제 금지).

## Tcl로 시작 프로젝트 만들기

```
# Vivado GUI Tcl Console:
cd <저장소>/W2_PL_Design/LAB01
source create_project.tcl
```

`./project_w2_pl/project_w2_pl.xpr`이 생성된다(RTL·TB만, 제약·BD 없음). 보드파일(Cora Z7-07S)이 먼저 설치돼 있어야 한다(교재 W1_S2 2.2절). 생성물 폴더는 `.gitignore` 처리됨.

> **경로 주의:** Vivado 빌드는 **짧은 로컬 경로**에서 한다. OneDrive·Dropbox 동기화 폴더 아래면 파일 잠금/권한 오류(`[Common 17-1293]`), 경로가 길면 Windows 260자 제한(`[Common 17-680]`)에 걸린다.

## 참고/검증 스크립트

`build_bd_reference.tcl`은 위 단순화된 BD를 System ILA까지 포함해 non-interactive로 재현하고 bitstream까지 돌린다. 수업용이 아니라 강의자 재현/점검용이다. GUI의 board automation이 없으므로 `sys_clock` 핀(H16) 제약만 스크립트가 따로 추가한다.

```
cd LAB01
# 짧은 경로로 빌드 (권장):
#   set env(W2_BUILD_DIR) C:/vw   (Tcl 콘솔)  또는  export W2_BUILD_DIR=C:/vw
vivado -mode batch -source build_bd_reference.tcl
```

**검증 상태:**
- `tb_pl_counter` behavioral simulation (`xsim`, Vivado 2023.2): `rst` 해제 후 `count`가 `tick`마다 +1, `div_count` 0→9 wrap — 정상 확인.
- GUI 전체 흐름(BD → ILA → wrapper → synth → I/O Planning → my.xdc → bitstream → 하드웨어 → ILA ALWAYS/BASIC): 화면 캡처로 확인됨(`../img/w2_f2.png` ~ `w2_f28.png`).
- `build_bd_reference.tcl`(단순화 설계로 갱신, 2026): **Vivado 재실행 미검증.** 실행 시 `[BD 41-1348]` critical warning은 정상. `dbg_hub` 관련 `PDCN-1569`/`RTSTAT-10` Warning도 정상.

## 재사용 출처

- `counter_n.v` / `pl_counter.v` 구조와 "clock-enable로 분주" 원칙:
  `Vitis_AI_platform_2026/ZynqSoc_Vitis2023/W1_PL/LAB/LAB01/rtl/` (Zybo Z7 대상) 를 Cora Z7-07S용으로 수정하고 LED 출력을 제거, ILA 관찰용 포트로 대체.
- ILA 개념(Probe/Trigger/Depth, `.ltx`, 캡처 창 계산, ALWAYS vs BASIC):
  같은 저장소 `W4_IRQ_ILA/` (삽입 방식만 "BD net 우클릭 Debug"로 변경).
