# W6 LAB03 — C로 밝기 바꾸기, ILA로 PWM 보기 (Cora Z7-07S)

6주차 3교시(W6_S3) 실습 파일. 교재 본문은 [`../W6_S3_Vitis_PWM_ILA.md`](../W6_S3_Vitis_PWM_ILA.md)(제3장).

> **상태: 초안.** C 코드는 보드에서 아직 실행하지 않았다. 레지스터 쓰기 순서와 값은 LAB01 테스트벤치(같은 순서의 AXI 쓰기)로 확인했다.

## 파일

```
LAB03/
└── src/
    ├── pwm_test.c    # 밝기 0 → 25 → 50 → 75 → 100 %를 1초마다. PERIOD 한 줄만 바꾸면 ILA용(200)
    └── pwm_fade.c    # for 문으로 1초 동안 밝게, 1초 동안 어둡게
```

`src`에는 한 번에 하나만 둔다(`main`이 둘이면 빌드 오류).

## 동작

| 코드 | `PERIOD` | 보드 | PuTTY(115200) |
|---|---|---|---|
| `pwm_test.c` | 50000 (1 ms) | shield LED 4개가 1초마다 꺼짐 → 25 → 50 → 75 → 100 % | `duty   0 %` … `duty 100 %` |
| `pwm_test.c` | 200 (4 µs) | 위와 같다(눈에는 차이 없음). ILA로 파형을 볼 때 쓴다 | 위와 같다 |
| `pwm_fade.c` | 50000 | 1초 동안 서서히 밝아지고 1초 동안 서서히 어두워진다 | `my_pwm fade start` |

## Vitis

- 작업 공간 `.../week6/vitis_ws`, Platform `platform`, Application `app_component`
- XSA: `.../week6/vivado_prj/custom_pwm/design_1_wrapper.xsa`
- `xparameters.h`: `XPAR_MY_PWM_0_BASEADDR 0x43c00000`
- **`invalid command name "ps7_init"`**: 5주차와 같은 Vitis 2023.2 버그. `launch.json`의 Initialization file을 `my_pwm.tcl` → `ps7_init.tcl`로 바꾼다.

## ILA 캡처 요약

| 캡처 | 트리거 | 보이는 것 |
|---|---|---|
| 1. PWM 파형 | `ila_led4` = `RRRR`(Rising) | 200샘플마다 펄스, 폭 = `DUTY`(50 / 100 / 150) |
| 2. DUTY 쓰기 순간 | `AWADDR = 8` 그리고 `AWVALID = 1`, 위치 512 | 트리거 앞은 이전 폭, 뒤는 새 폭. `WDATA` = 새 `DUTY` |

- `Probes file`은 `.../week6/vivado_prj/custom_pwm/custom_pwm.runs/impl_1/design_1_wrapper.ltx`.
- `DUTY = 0`(0 %)과 `DUTY = PERIOD`(100 %)에서는 `led4`가 바뀌지 않으므로 캡처 1의 트리거가 걸리지 않는다.
