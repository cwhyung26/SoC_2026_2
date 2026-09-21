# W4 LAB02 — AXI GPIO #2(shield) + `XGpio` 드라이버 (Cora Z7-07S)

4주차 2교시(W4_S2) 실습 파일. 교재 본문은 [`../W4_S2_AXI_GPIO_Driver.md`](../W4_S2_AXI_GPIO_Driver.md)(제8장).

> **상태: 실기기 검증 완료.** 프로젝트 복사부터 Vitis 빌드·실행까지 전 과정을 캡처로 확인했다.

## 이번 LAB은 `LAB01`을 복사해서 이어 간다 — 새 프로젝트가 아니다

2~3주차와 달리 이번엔 프로젝트를 처음부터 다시 만들지 않는다. `LAB01`에서 만든 `lab01` 프로젝트를 **`File → Save Project As…`로 `lab02b`라는 이름으로 복사**한 뒤, 그 복사본에 AXI GPIO #2를 추가하는 **확장** 작업이다. 반복을 통한 툴체인 숙달은 3주차까지로 충분하다고 판단했고, 이제부터는 기존 설계를 이어서 키우는 방식(실제 개발에 더 가까운 방식)으로 진행한다.

`lab01`을 직접 고치지 않고 복사하는 이유: `lab01`(과 그 위의 Vitis Platform·Application)을 손대지 않은 체크포인트로 남겨 두기 위해서다. Vitis 쪽도 마찬가지로 1교시의 `w4_platform`/`lab01_app`을 그대로 두고, `lab02b`가 새로 Export한 `.xsa`를 가리키는 **새 Platform(`w4s2_platform`)·Application(`lab02_app`)**을 만든다. (복사는 `File → Save Project As…`로 한다.)

## 이번 LAB의 설계

`boards/board_summary.pdf`(13~14페이지)의 Arduino/ChipKit shield 확장을 사용한다. AXI GPIO #2를 듀얼 채널(채널1=입력 4비트=shield 스위치, 채널2=출력 4비트=shield LED)로 구성한다.

```
LAB02/
├── xdc/
│   └── cora_z7_07s_week04_shield.xdc   # Import할 파일. board_summary.pdf 핀 배정 그대로.
└── src/
    └── btn_led_sw_driver.c              # XGpio 드라이버로 AXI GPIO #1+#2 둘 다 제어
```

## 핵심 포인트

- **AXI 슬레이브가 2개가 되면 Address Editor에 주소가 2줄** — `axi_gpio_0/S_AXI`는 `0x4120_0000`(1교시와 동일), `axi_gpio_1/S_AXI`는 `0x4121_0000`. 실기기로 확인됨(둘 다 Range 64K).
- **HDL Wrapper "안 생기는" 문제의 진짜 원인은 편집기 탭이다.** 7장에서 "Let Vivado manage wrapper and auto-update"로 만들어 뒀으므로 `Create HDL Wrapper`를 또 실행할 필요는 없다. 다만 (1) Block Design을 **저장**해야 하고(래퍼는 디스크의 `.bd`를 읽는다), (2) `Reset Output Products` → `Generate Output Products`(또는 `Run Synthesis`)로 재생성해야 하며, (3) **`design_1_wrapper.v`를 탭으로 열어 둔 상태였다면 파일 위 노란 막대의 `Reload`를 눌러야 새 내용이 보인다.** 실기기에서 막혔던 지점이 바로 (3)이었다.
- **인터페이스(`GPIO`) vs 멤버 신호(`gpio_io_i`) Make External** — 회로는 같지만 top 포트 이름이 달라진다. 인터페이스를 내보내면 멤버에 맞춰 접미사가 붙어 `btn_tri_i`/`led0_tri_o`처럼 되고(7장 방식), 멤버 신호를 내보내면 접미사 없이 `sw4[3:0]`/`led4[3:0]`이 된다(8장 방식). 실기기 래퍼에서 네 이름이 한꺼번에 확인됨: `btn_tri_i, led0_tri_o, led4, sw4`.
- **XDC Import**: `Add Sources → Add or create constraints → Add Files`로 기존 제약 파일을 프로젝트에 추가하는 방법. 핀이 많을 때(이번엔 8개) 하나씩 입력하는 대신 쓴다. `Copy constraints files into project`를 체크하지 않으면 저장소의 `LAB02/xdc/` 파일을 그대로 참조한다.
- **`lab02b`엔 이미 `my.xdc`(7장, btn/led0)가 있다 — 겹쳐도 된다.** 새로 Import하는 `cora_z7_07s_week04_shield.xdc`는 `btn`/`led0`가 아니라 **다른 포트**(`sw4`/`led4`)를 배정하므로 충돌하지 않는다. 한 프로젝트에 XDC 파일을 여러 개 두고 Vivado가 전부 합쳐서 적용하는 것은 정상적인 방식이며, 오히려 기능별로 나누는 쪽이 실무에 가깝다. 문제가 되는 경우는 **같은 포트**가 두 XDC 파일에서 서로 다른 핀으로 배정될 때뿐이다.
- **포트 이름이 정확히 일치해야 한다.** `cora_z7_07s_week04_shield.xdc`는 멤버 신호 방식 + Make External 이름 `sw4`/`led4`를 전제로 `sw4[0..3]`(U15/K18/J18/G15), `led4[0..3]`(T14/V17/R17/N18)로 작성했다. 실기기 I/O Planning에서 이 이름으로 핀 8개가 모두 배정되는 것을 확인했다.
- **`XGpio` 드라이버**(`Initialize`/`SetDataDirection`/`DiscreteWrite`/`DiscreteRead`)로 `LAB01`의 레지스터 코드와 같은 동작을 다시 짠다 — 채널 번호만 넘기면 오프셋 계산은 드라이버가 대신한다.

## 검증 결과

- **전 과정 실기기 확인 완료**: 프로젝트 복사(`lab02b`) → AXI GPIO #2 → Address Editor 2줄 → 래퍼 갱신 → XDC Import → I/O 확인 → Bitstream·Export → Vitis(`lab02_platform`/`lab02_app`) 빌드 → 실행(PuTTY 로그).
- **`XGpio`는 3주차 `XGpioPs`와 달리 손볼 것이 없었다.** `XPAR_AXI_GPIO_0_BASEADDR`/`XPAR_AXI_GPIO_1_BASEADDR`가 그대로 생성되고, `XGpio_Initialize(&gpio, 베이스주소)` 형태가 이 플랫폼의 SDT(`-DSDT`) 빌드에서 그대로 통과한다.
- Vitis 컴포넌트 이름: Platform `lab02_platform`, Application `lab02_app`(7장의 `w4_platform`/`lab01_app`은 그대로 남겨 둔다). Application 생성 시 **Platform을 `lab02_platform`으로 고르는 것**에 주의 — `w4_platform`을 고르면 AXI GPIO가 하나뿐인 예전 하드웨어로 빌드된다.

## 남은 일

- `img/w4s2_19.HEIC`(동작 사진)를 **`w4s2_19.jpg`로 변환**해야 한다. HEIC는 GitHub·마크다운에서 렌더링되지 않는다. 본문(그림 8-25)은 이미 `w4s2_19.jpg`를 참조하도록 작성해 두었고, 이 사진은 shield 배선 참고용으로 8.4절에서도 가리키고 있다.

## 다음 주 예고

제5주: 인터럽트 — PS가 폴링 대신 PL의 이벤트(AXI GPIO 인터럽트 출력)를 기다리는 방식으로 이 회로를 확장한다.
