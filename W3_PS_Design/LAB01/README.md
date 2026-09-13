# W3 LAB01 — PS만으로 Hello World (Cora Z7-07S)

3주차 1교시(W3_S1) 실습 파일. 교재 본문은 [`../W3_S1_PS_Intro_Vitis_HelloWorld.md`](../W3_S1_PS_Intro_Vitis_HelloWorld.md)(제5장).

> **상태: 처음부터 끝까지(Vivado → Vitis → 빌드·실행 → 터미널 출력) 전부 실기기 캡처로 확인됨(`img/w3s1_01.png`~`35.png`).** UART 출력 확인은 PuTTY로 검증했다 — Vitis 자체 Serial Terminal 메뉴 위치는 확인하지 못해 본문에서 다루지 않는다.

## 이번 LAB의 설계

PL에 로직 없음. `ZYNQ7 Processing System` 블록 하나 + Block Automation(Apply Board Preset)만으로 최소 하드웨어를 만들고, Vitis에서 `helloworld.c`를 **Import**해 빌드·실행하여 UART 출력을 확인한다. Vitis 기본 "Hello World" 템플릿을 그대로 쓰지 않고 `src/helloworld.c`를 미리 준비해 둔 것은, 교재에 실린 코드와 학생이 실제로 빌드하는 코드를 정확히 같게 하기 위해서다.

Vivado 프로젝트 이름: `lab01` (실제 캡처 기준). 새 프로젝트를 **처음부터** 만든다 — W2의 `LAB01`을 이어 쓰지 않는다.

```
LAB01/
├── src/
│   └── helloworld.c   # Vitis Empty Application (C) → src 우클릭 → Import Sources로 가져올 완성 코드
└── README.md
```

## W3_LAB01과 W3_LAB02의 관계 — 일부러 별개의 LAB이다

W3_S2(`LAB02`)는 이번 LAB01과 회로 설계가 거의 같다(PS 블록 + Block Automation). 그런데도 **W3_S2는 이 프로젝트를 이어 쓰지 않고 처음부터 새 프로젝트를 다시 만든다.**

이는 실수나 중복이 아니라 의도된 구성이다. 학기 초반, 특히 Vivado/Vitis 툴체인이 아직 낯선 시기에는 "New Project → Block Design → PS 추가 → Block Automation → Export Hardware → Vitis Platform/Application"이라는 **틀 자체를 손으로 반복**하는 것이 다음에 새 설계를 만날 때 절차를 헤매지 않게 하는 데 더 효과적이다. (연구원 대상 자료처럼 "한 번 만든 프로젝트를 이어서 확장"하는 방식과는 이 학기 초반만큼은 다르게 간다.)

## 핵심 포인트

- PS의 기준 클럭(`PS_CLK`, 50 MHz)은 PL의 125 MHz 클럭과 완전히 별개다.
- Cora Z7-07S에서 PS(MIO)에 연결된 것: UART(USB-JTAG/UART 콤보), Gigabit Ethernet, microSD, QSPI Flash.
- PL 핀에 연결된 것(PS만으로 접근 불가, EMIO 필요): 버튼 `BTN0`(D20)/`BTN1`(D19), RGB LED 2개.

## 남은 참고 사항

- **Vitis 자체의 Serial Terminal 메뉴 위치는 확인하지 못했다.** UART 출력은 PuTTY로 확인했고(5.10절), 본문은 PuTTY만 가르친다. Vitis Serial Terminal 위치를 찾으면 별도 보충 섹션으로 추가할 수 있다.

## 실기기로 확인된 것 (2026-09-13)

- 프로젝트 생성부터 Export Hardware까지(본문 5.2~5.6절, `img/w3s1_01.png`~`16.png`) 전 과정이 실제 Vivado 2023.2 + Cora Z7-07S로 확인되었다.
- PS 재구성 창의 페이지 구성은 `Zynq Block Design`(개요) → `PS-PL Configuration` → `Peripheral I/O Pins` → `MIO Configuration` → `Clock Configuration` 순.
- 보드 프리셋이 활성화하는 MIO 페리페럴은 `ENET 0`(16..27) · `USB 0`(28..39) · `SD 0`(40..45) · `UART 0`(14..15).
- Clock Configuration: 입력 50 MHz → `CPU` 650 MHz, `DDR` 525 MHz, `FCLK_CLK0`(PS→PL) 50 MHz.
- `PS-PL Configuration`의 `M AXI GP0 interface`는 **이번 주는 의도적으로 꺼 둔다** — 4주차(AXI GPIO)에 켠다.
- **Vitis 2023.2는 Vitis Unified IDE다** (Eclipse 기반 Classic이 아니다). Workspace(`vitis_workspace`) → `Create Platform Component`(`w3s1_platform`, XSA=`design_1_wrapper.xsa`) → `FLOW → Build`로 플랫폼을 직접 빌드 → `Create Embedded Application`(`w3s1_app`) → `src` 우클릭 → `Import → Files…`로 `helloworld.c` 가져오기, 전 과정이 실기기로 확인되었다(본문 5.7~5.8절, `img/w3s1_17.png`~`30.png`).

## 다음 LAB

`LAB02`(W3_S2): 새 프로젝트를 다시 만들어 EMIO로 RGB LED 하나를 제어한다. [`../LAB02/README.md`](../LAB02/README.md).
