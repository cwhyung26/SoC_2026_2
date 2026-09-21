# W4 LAB01 — AXI GPIO #1, 레지스터 직접 접근 (Cora Z7-07S)

4주차 1교시(W4_S1) 실습 파일. 교재 본문은 [`../W4_S1_AXI_GPIO_Register.md`](../W4_S1_AXI_GPIO_Register.md)(제7장).

> **상태: 초안, 실기기 미검증.** 본문의 `📷 [촬영]` 표시가 스크린샷 자리이며, 실습을 진행하면서 캡처를 넣고 필요하면 절차를 바로잡는다.

## 이번 LAB의 설계

PL에 처음으로 진짜 IP(AXI GPIO)가 들어간다. PS의 `M AXI GP0`을 켜고, AXI GPIO 1개를 듀얼 채널(채널1=입력 2비트, 채널2=출력 3비트)로 구성해 Cora Z7-07S의 `BTN0`/`BTN1`과 RGB LED0을 직접 연결한다.

```
LAB01/
├── xdc/
│   └── cora_z7_07s_week04_lab01.xdc   # 참고용 답안. 포트 이름은 실습 중 재확인
└── src/
    └── btn_led_reg.c                   # Xil_Out32/Xil_In32로 AXI GPIO 레지스터 직접 접근
```

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
