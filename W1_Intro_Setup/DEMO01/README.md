# DEMO01 — W1_S2 Vivado 설계 흐름 시연용 예제

이 폴더는 학생이 직접 수행하는 LAB이 아니라, **강의자가 W1_S2에서 Vivado 화면을 보여주기 위한 시연용 예제**다. 채점 대상이 아니다.

## 구성

```
DEMO01/
├── rtl/
│   └── led_counter_demo.v      # 클럭 분주 + 4비트 카운터 (합성/구현/비트스트림 시연용)
└── sim/
    └── tb_led_counter_demo.v   # 위 모듈을 빠르게 관찰하기 위한 테스트벤치 (시뮬레이션 시연용)
```

## 사용 방법

1. Vivado에서 **Create Project** → RTL Project → `rtl/led_counter_demo.v`를 Design Sources로 추가한다.
2. Boards 탭에서 Cora Z7-07S(보드파일 설치 후) 또는 Parts 탭에서 `xc7z007s`를 Default Part로 선택한다.
3. Design Sources에 `led_counter_demo`가 Top Module로 표시되는지 확인한다.
4. **의도적으로 XDC(핀 배정)를 추가하지 않는다.** 2주차에 실제 보드가 배부된 뒤 정식으로 핀을 배정한다.
5. Flow Navigator에서 Synthesis → Implementation → Generate Bitstream을 순서대로 실행한다.
   - Bitstream 생성 시 "핀이 배정되지 않았다"는 Critical Warning이 나타난다. 이는 정상이며, XDC가 왜 필요한지 보여주는 교육적 장치다.
   - Hardware Manager로 실제 보드에 Program하는 단계는 진행하지 않는다 (보드 미배부).
6. 시간이 남으면 `sim/tb_led_counter_demo.v`를 Simulation Sources로 추가하고 **Run Simulation → Run Behavioral Simulation**을 실행해 `led`가 증가하는 파형을 확인한다.
