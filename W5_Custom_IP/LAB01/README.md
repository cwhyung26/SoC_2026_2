# W5 LAB01 — 사용자 IP `my_io` 만들기 (Cora Z7-07S)

5주차 1교시(W5_S1) 실습 파일. 교재 본문은 [`../W5_S1_Custom_IP_Create.md`](../W5_S1_Custom_IP_Create.md)(제1장).

> **상태: 초안.** Vivado 2023.2 배치 모드로 IP 생성·수정·Re-Package·Bitstream까지 확인했다. GUI 화면 캡처와 실기기 동작은 아직 확인하지 않았다.

## 파일

```
LAB01/
└── hdl/
    ├── my_io_v1_0.v            # 바깥 포장: 포트 4개 선언 + 안쪽 인스턴스 연결
    └── my_io_v1_0_S00_AXI.v    # 레지스터: 포트 4개, 읽기 case 2줄, assign 2줄
```

두 파일은 `Create and Package New IP`가 만든 템플릿을 1.6절대로 고친 **완성본**이다. 먼저 직접 고친 뒤 막히면 비교한다. 파일을 통째로 덮어쓰면 무엇을 고쳤는지 배울 수 없다.

## 레지스터 맵

| 주소 | 방향 | 연결 |
|---|---|---|
| `+0x0` | 쓰기 | `led4[3:0]` (shield LED) — `slv_reg0[3:0]` |
| `+0x4` | 쓰기 | `led3[2:0]` (RGB LED1) — `slv_reg1[2:0]` |
| `+0x8` | 읽기 | `sw4[3:0]` (shield 스위치) |
| `+0xC` | 읽기 | `btn2[1:0]` (BTN0, BTN1) |

## 템플릿 대비 바뀐 곳 (다섯 군데)

| 파일 | 위치(찾을 문자열) | 내용 |
|---|---|---|
| `my_io_v1_0_S00_AXI.v` | `Users to add ports here` | 포트 4개 선언 |
| `my_io_v1_0_S00_AXI.v` | `reg_data_out` | `2'h2` → `{28'd0, sw4}`, `2'h3` → `{30'd0, btn2}` |
| `my_io_v1_0_S00_AXI.v` | `Add user logic here` | `assign led4 = slv_reg0[3:0];` `assign led3 = slv_reg1[2:0];` |
| `my_io_v1_0.v` | `Users to add ports here` | 포트 4개 선언 |
| `my_io_v1_0.v` | `my_io_v1_0_S00_AXI_inst (` | `.led4(led4)` 등 4줄 연결 |

AXI 핸드셰이크 부분(`axi_awready`, `axi_wready`, `axi_bvalid`, `axi_arready`, `axi_rvalid`)과 쓰기 `case`(`slv_reg_wren`)는 고치지 않는다.

## 확인한 것

- Vivado 2023.2가 만드는 템플릿의 읽기 부분은 `case ( axi_araddr[...] )` / `2'h0 : reg_data_out <= slv_reg0;` 형태다(본문 1.5절 코드는 실제 생성 코드 그대로).
- Re-Package 후 IP 포트: `btn2`, `led3`, `led4`, `sw4` + `s00_axi_*`.
- 템플릿과 함께 생성되는 Vitis용 드라이버(`drivers/my_io_v1_0/`, `MY_IO_mWriteReg` 매크로)는 2023.2 Vitis(SDT) 플랫폼의 BSP에 **포함되지 않는다.** 빌드 오류는 없지만 쓸 수 없으므로 3장에서는 `Xil_In32`/`Xil_Out32`를 쓴다.

## 다음 LAB

[`../LAB02/README.md`](../LAB02/README.md) — 이 IP를 Block Design에 넣고 System ILA를 붙인다(제2장).
