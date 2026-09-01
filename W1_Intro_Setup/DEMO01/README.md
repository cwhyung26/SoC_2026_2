# DEMO01 — W1_S2 Vivado 설계 흐름 시연용 예제

이 폴더는 학생이 직접 수행하는 LAB이 아니라, **강의자가 W1_S2에서 Vivado 화면을 보여주기 위한 시연용 예제**다. 채점 대상이 아니다. 수업에서는 강사가 New Project 마법사부터 Bitstream 생성까지 손으로 시연하고, 학생은 화면을 관찰한다.

## 구성

```
DEMO01/
├── rtl/
│   └── led_counter_demo.v          # 클럭 분주 + 4비트 카운터 (합성/구현/비트스트림 시연용)
├── sim/
│   └── tb_led_counter_demo.v       # 위 모듈을 빠르게 관찰하기 위한 테스트벤치 (시뮬레이션 시연용)
├── constraints/
│   └── led_counter_demo.xdc        # Cora Z7-07S 핀 배정 (clk=H16, rst_n=BTN0, led→RGB LED)
└── create_demo01_project.tcl       # 위 프로젝트를 그대로 재현하는 Tcl 스크립트 (과제·복습용)
```

## 시연 순서 (교재 2.3~2.6절)

1. **프로젝트 생성** — Create Project → RTL Project → `rtl/led_counter_demo.v`를 Design Sources로 추가 → Boards 탭에서 Cora Z7-07S 선택 → Finish.
2. **Vivado 화면 구성** — 프로젝트가 열린 상태에서 Flow Navigator / Sources / IP Catalog / Tcl Console / Messages 위치를 설명한다.
3. **시뮬레이션** — `sim/tb_led_counter_demo.v`를 Simulation Sources로 추가하고 **Run Simulation → Run Behavioral Simulation**을 실행해 `led`가 증가하는 파형을 확인한다.
4. **합성 → 구현 → Bitstream** — Flow Navigator에서 Synthesis → Implementation → Generate Bitstream을 순서대로 실행한다.
   - `constraints/led_counter_demo.xdc` 로 `clk`·`rst_n`·`led` 를 Cora Z7-07S 핀에 배정해 둔다. **XDC가 없으면 Generate Bitstream이 DRC 에러(`UCIO-1`/`NSTD-1`)로 멈춘다** — 이 XDC의 각 줄이 무엇을 하는지, 왜 필요한지 설명한다.
   - Cora Z7-07S는 단색 LED가 없어 `led[3:0]` 을 RGB LED(LD0/LD1) 채널에 매핑했다. 버튼은 active-high라서 `rst_n`(active-low)과 극성이 반대인데, 이 정리는 2주차 주제다.
   - Hardware Manager로 실제 보드에 Program하는 단계는 진행하지 않는다 (보드 미배부).

## 스크립트로 재현하기

수업을 못 따라온 학생이나 복습용으로, 위와 똑같은 프로젝트를 한 번에 만들 수 있다.

```
# Vivado GUI의 Tcl Console에서:
cd <이 DEMO01 폴더의 경로>
source create_demo01_project.tcl

# 또는 명령창에서 배치 실행:
vivado -mode batch -source create_demo01_project.tcl
```

`DEMO01/project_demo01/project_demo01.xpr` 이 생성된다. 이후 Flow Navigator에서 Run Synthesis → Run Implementation → Generate Bitstream을 실행하면 시연과 동일한 결과를 얻는다. (보드파일이 먼저 설치돼 있어야 한다 — 교재 2.2절)

> `project_demo01/` 폴더는 생성 결과물이므로 저장소에 커밋하지 않는다.
