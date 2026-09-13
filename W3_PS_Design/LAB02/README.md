# W3 LAB02 — EMIO로 LED 제어 (Cora Z7-07S)

3주차 2교시(W3_S2) 실습 파일. 교재 본문은 [`../W3_S2_PS_EMIO_LED.md`](../W3_S2_PS_EMIO_LED.md)(제6장).

> **상태: 처음부터 끝까지(Vivado → Vitis → 빌드·실행 → LED·UART 확인) 전부 실기기 캡처로 확인됨(`img/w3s2_01.png`~`28.png`).**

## 이번 LAB은 새 프로젝트다 — `LAB01`을 이어 쓰지 않는다

이 LAB은 `LAB01`(제5장, PS 블록 + Block Automation)과 회로가 거의 같다. 그런데도 **처음부터 새 Vivado 프로젝트(`lab02`)를 만들고, PS 블록 추가·Block Automation·HDL Wrapper·Export Hardware·Vitis Platform/Application까지 절차를 전부 다시 밟는다.** `LAB01`의 이유와 같다 — 설계가 겹치더라도 툴체인 절차를 반복해서 손에 익히는 것이 이번 학기 초반의 목표다. [`../LAB01/README.md`](../LAB01/README.md)의 설명 참고.

이번 LAB에서 새로 추가되는 것은 딱 하나, **PS GPIO를 EMIO 1비트로 빼서 RGB LED0의 빨간 채널을 제어**하는 부분이다.

## 구성

```
LAB02/
├── xdc/
│   └── cora_z7_07s_week03.xdc   # 참고용. led_out_tri_io[0] → N15 (LVCMOS33) 하나뿐.
└── src/
    └── led_emio.c                # Vitis Empty Application (C) → src 우클릭 → Import → Files…로 가져올 완성 코드
                                   #   (드라이버 API 없이 레지스터 주소 3개(DIRM_2/OEN_2/DATA_2)만 직접 Xil_Out32)
```

## 핵심 포인트

- Zynq-7000 GPIO는 32비트씩 4개 뱅크(0~31/32~53/**54~85**/86~117)로 나뉜다. `EMIO GPIO` 폭 1로 만든 첫 EMIO 비트(핀 번호 54)는 **Bank 2의 0번 비트**다.
- `led_emio.c`는 `xgpiops` 드라이버 API(`XGpioPs_Config`/`CfgInitialize`/`SetDirectionPin`/…)도, `xparameters.h`도 쓰지 않는다. `DIRM_2`(`0xE000A284`)·`OEN_2`(`0xE000A288`)·`DATA_2`(`0xE000A048`) **세 레지스터 주소에 `Xil_Out32`로 직접 쓴다** — 이 설계가 EMIO 비트를 1개만 쓰므로 read-modify-write 없이 통째로 써도 안전하다(비트를 늘리면 read-modify-write로 바꿔야 한다).
- RGB LED 핀: LED0 R=`N15` G=`G17` B=`L15`, LED1 R=`M15` G=`L14` B=`G14`. 이번 LAB은 `N15`(LED0의 R)만 사용.
- PL 로직은 여전히 0개 — EMIO는 배선만 추가한다.
- **BD 포트 이름과 합성 후 포트 이름이 다르다.** GPIO_0 인터페이스를 Make External 하면 BD에서는 `led_out`으로 보이지만, EMIO GPIO는 `GPIO_I`/`GPIO_O`/`GPIO_T` 3-상태(tri-state) 신호를 묶은 것이라 합성 후 실제 top-level 포트 이름은 **`led_out_tri_io[0]`** 이 된다. I/O Planning·XDC에서는 이 이름을 써야 한다.

## 실기기로 확인된 것 (2026-09-13)

- 프로젝트 생성부터 Export Hardware까지(본문 6.2~6.6절, `img/w3s2_01.png`~`16.png`) 전 과정이 실제 Vivado 2023.2 + Cora Z7-07S로 확인되었다.
- MIO Configuration의 GPIO 항목: `GPIO MIO`(보드 프리셋 기본 체크) 아래 `EMIO GPIO (Width)`를 체크하고 폭을 `1`로 입력한다.
- Make External 결과 BD 포트 이름은 `led_out`, 합성 후 top-level 포트 이름은 `led_out_tri_io[0]` — 위 핵심 포인트 참고.
- PS-PL Configuration의 `M AXI GP0 interface`는 1교시와 마찬가지로 꺼진 채로 유지된다(그대로 둔다).
- **Vitis Platform/Application 생성 → 빌드까지 실기기로 확인.** 처음엔 `xgpiops` 드라이버 API(`XGpioPs_LookupConfig(XPAR_XGPIOPS_0_DEVICE_ID)`)로 작성했다가 `undeclared` 에러를 만났다 — 이 플랫폼은 System Device Tree(SDT) 방식(`-DSDT`)이라 `xparameters.h`에 `_DEVICE_ID` 매크로가 아예 없고 `XPAR_XGPIOPS_0_BASEADDR`(`0xe000a000`)만 있다. 이후 드라이버 API 자체를 쓰지 않는 레지스터 직접 접근으로 바꿔 이 문제를 피했고, 다시 한번 단순화해 **레지스터 절대 주소 3개(`DIRM_2`/`OEN_2`/`DATA_2`)만 남긴 최소 버전**으로 정리했다(`xparameters.h`·`xgpiops_hw.h` 둘 다 불필요, `xil_io.h`의 `Xil_Out32`만 사용). 주소는 베이스 `0xE000A000` + `xgpiops_hw.h` 오프셋으로 계산했고, 뱅크 2 = 핀번호 54~85라는 것은 `xgpiops.c`의 `XGpioPs_GetBankPin()` 주석과 대조해 확인했다.

## 다음 주 예고

제4주: PS-PL을 AXI 버스로 연결(AXI GPIO IP), 버튼 입력을 EMIO가 아니라 AXI GPIO로 받는 구조로 확장.
