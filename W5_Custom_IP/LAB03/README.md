# W5 LAB03 — Vitis로 `my_io` 읽고 쓰기, ILA로 보기 (Cora Z7-07S)

5주차 3교시(W5_S3) 실습 파일. 교재 본문은 [`../W5_S3_Vitis_ILA.md`](../W5_S3_Vitis_ILA.md)(제3장).

> **상태: 초안.** Vitis 2023.2로 Platform(`platform`)·Application(`app_component`) 빌드까지 확인했다. **보드 실행과 ILA 캡처는 실기기에서 아직 확인하지 않았다.** 특히 Hardware Manager에 표시되는 AXI 신호 이름(`ARVALID`, `AWVALID` 등)과 파형 모양은 실습 전에 한 번 확인해 본문을 맞춘다.

## 파일

```
LAB03/
└── src/my_io_test.c    # 0.2초마다: sw4 읽기 → btn2 읽기 → led4에 쓰기 → led3에 쓰기
```

## 동작

| 입력 | 결과 |
|---|---|
| shield 스위치 | 같은 자리의 shield LED가 켜진다 |
| BTN0 / BTN1 / 둘 다 | RGB LED1이 빨강 / 초록 / 노랑 |

PuTTY(115200)에 `sw = .. btn = ..`이 0.2초마다 찍힌다.

## Vitis 쪽에서 확인한 것

- `xparameters.h`: `XPAR_MY_IO_0_BASEADDR 0x43c00000`, `XPAR_MY_IO_0_HIGHADDR 0x43c0ffff`
- IP와 함께 생성된 `my_io` 드라이버(`MY_IO_mWriteReg` 등)는 BSP에 포함되지 **않는다.** 빌드 오류는 없다. 코드는 `Xil_Out32`/`Xil_In32`만 쓴다.
- ILA는 소프트웨어에 영향을 주지 않는다(ILA를 넣기 전·후 `.xsa` 모두 같은 코드가 빌드된다).

## ILA 캡처 요약

| 캡처 | 트리거 | 보이는 것 |
|---|---|---|
| 1. 한 바퀴 | AXI 슬롯 `ARVALID = 1`, 위치 100 | 읽기 `43C00008` → 읽기 `43C0000C` → 쓰기 `43C00000`(`led4` 변화) → 쓰기 `43C00004`(`led3` 변화) |
| 2. 한 줄 | `AWVALID = 1`, Vitis Debug에서 `Xil_Out32(REG_LED4, sw)`를 Step Over | 쓰기 `0` 하나와 그 순간의 `led4` 변화 |

- Hardware Manager는 Vitis로 실행한 **뒤** 연결하고, `Program Device`는 누르지 않는다. Vitis Debug를 새로 시작하면 보드가 다시 프로그래밍되므로 `Refresh Device`를 다시 한다.
- `Probes file`은 2장 Bitstream과 함께 생긴 `.../week5/vivado_prj/custom_ip/custom_ip.runs/impl_1/design_1_wrapper.ltx`.
- Vitis 작업 공간은 `.../week5/vitis_ws`, Platform의 XSA는 `.../week5/vivado_prj/custom_ip/design_1_wrapper.xsa`.
