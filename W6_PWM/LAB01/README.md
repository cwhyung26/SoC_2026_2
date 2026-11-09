# W6 LAB01 — PWM IP `my_pwm` 만들기 (Cora Z7-07S)

6주차 1교시(W6_S1) 실습 파일. 교재 본문은 [`../W6_S1_PWM_IP_Create.md`](../W6_S1_PWM_IP_Create.md)(제1장).

> **상태: 초안.** 테스트벤치로 PWM 동작을 시뮬레이션했고(xsim), Vivado 2023.2 배치 모드로 IP 생성·수정·Re-Package·Bitstream까지 확인했다. GUI 화면 캡처와 실기기 동작은 아직 확인하지 않았다.

## 파일

```
LAB01/
├── hdl/
│   ├── my_pwm_v1_0.v            # 바깥 포장: ③ 포트 led4, ④ 인스턴스 연결
│   └── my_pwm_v1_0_S00_AXI.v    # ① 포트 led4, ② user logic (이름 → 카운터 → 비교기)
└── sim/
    └── tb_my_pwm.v              # (선택) AXI 쓰기로 PERIOD/DUTY/CTRL을 쓰고 켜진 클럭 수를 센다
```

`hdl/`의 두 파일은 `Create and Package New IP`가 만든 템플릿을 1.6절대로 고친 **완성본**이다. 먼저 직접 고친 뒤 막히면 비교한다.

## 레지스터 맵

| 주소 | 이름 | 방향 | 비트 | 뜻 |
|---|---|---|---|---|
| `+0x0` | `CTRL` | 쓰기 | `[0]` | 1 = 동작, 0 = 정지(LED 꺼짐) |
| `+0x4` | `PERIOD` | 쓰기 | `[15:0]` | 한 주기의 길이(클럭 수). 50 MHz에서 50000 = 1 ms |
| `+0x8` | `DUTY` | 쓰기 | `[15:0]` | 한 주기 중 켜진 시간(클럭 수) |
| `+0xC` | — | — | — | 쓰지 않는다 |

네 레지스터 모두 쓴 값이 그대로 읽힌다(읽기 `case`는 템플릿 그대로).

## user logic

```verilog
wire        en     = slv_reg0[0];
wire [15:0] period = slv_reg1[15:0];
wire [15:0] duty   = slv_reg2[15:0];

reg [15:0] pwm_cnt;

always @( posedge S_AXI_ACLK )
begin
  if ( en == 0 )                       pwm_cnt <= 0;
  else if ( pwm_cnt >= period - 1 )    pwm_cnt <= 0;
  else                                 pwm_cnt <= pwm_cnt + 1;
end

assign led4 = ( en == 1 && pwm_cnt < duty ) ? 4'b1111 : 4'b0000;
```

- 클럭은 `S_AXI_ACLK`(= `FCLK_CLK0`, 50 MHz) 하나. 분주기와 별도 클럭이 없어 CDC 문제가 없다.
- 리셋 뒤 `slv_reg0 = 0`이라 `en = 0` → 카운터는 다음 클럭에 0이 된다.
- `DUTY ≥ PERIOD`면 계속 켜짐, `DUTY = 0`이면 계속 꺼짐.

## 시뮬레이션 결과 (xsim, Vivado 2023.2)

```text
PERIOD   200  DUTY    50 : led4 high    50 of   200 clocks (exp    50)  OK
PERIOD   200  DUTY   150 : led4 high   150 of   200 clocks (exp   150)  OK
PERIOD   200  DUTY     0 : led4 high     0 of   200 clocks (exp     0)  OK
PERIOD   200  DUTY   200 : led4 high   200 of   200 clocks (exp   200)  OK
PERIOD 50000  DUTY 12500 : led4 high 12500 of 50000 clocks (exp 12500)  OK
EN = 0 : led4 high 0 of 1000 clocks (exp 0), DUTY reads back 12500
```

명령줄로 돌릴 때:

```
xvlog hdl/my_pwm_v1_0_S00_AXI.v sim/tb_my_pwm.v
xelab tb_my_pwm -s sim
xsim sim -R
```

## 다음 LAB

[`../LAB02/README.md`](../LAB02/README.md) — Block Design, System ILA, Bitstream(제2장).
