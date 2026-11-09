# 6주차 스크린샷 캡처 목록

본문은 아래 파일명을 이미 참조하도록 작성되어 있다. 캡처해서 `img/`에 이 이름으로 저장하고, 본문 캡션 끝의 **`📷 *캡처 대기*`** 표시를 지우면 된다. 파일명에 설명을 붙여 넣어 주면(예: `스크린샷 … (DUTY 쓰기 순간).png`) 그 내용에 맞춰 이름을 바꾸고 위치를 잡는다.

빠진 그림 번호(1-1, 1-2, 1-3, 1-10, 2-1, 2-13, 3-2, 3-4, 3-6)는 개념 다이어그램이다. `img/w6_*.svg`로 이미 들어 있으므로 캡처하지 않는다.

5주차에 캡처한 화면(Create and Package New IP의 나머지 단계, Re-Package, IP 저장소 등록, Connection Automation, External Port Properties, Export, Vitis Workspace·Import, `launch.json`, Hardware Manager 연결)은 다시 캡처하지 않고 5주차 그림 번호로 안내한다. **이번 주에 처음 나오거나 내용이 달라지는 화면만** 캡처한다.

## 1교시 — [W6_S1_PWM_IP_Create.md](W6_S1_PWM_IP_Create.md) (제1장)

| 파일명 | 그림 | 담을 내용 | 상태 |
|---|---|---|---|
| `img/w6s1_01.png` | 그림 1-4 | New Project — `custom_pwm`, `…/week6/vivado_prj` | ✅ |
| `img/w6s1_02.png` | 그림 1-5 | `Create a new AXI4 peripheral` 선택 | ✅ |
| `img/w6s1_03.png` | 그림 1-6 | `Peripheral Details` — Name `my_pwm`, IP location `…/custom_pwm/../ip_repo` | ✅ |
| `img/w6s1_04.png` | 그림 1-7 | `Add Interfaces` — Lite, Slave, 32, Number of Registers 4 | ✅ |
| `img/w6s1_05.png` | 그림 1-8 | `Create Peripheral` — Next Steps `Edit IP` | ✅ |
| `img/w6s1_06.png` | 그림 1-9 | `edit_my_pwm_v1_0` 창 — Sources 계층, Package IP 탭 | ✅ |
| `img/w6s1_07.png` | 그림 1-11 | 고치기 전 `Users to add ports here`(17~19줄) | ✅ |
| `img/w6s1_08.png` | 그림 1-12 | 고치기 전 `Add user logic here`(400~402줄) | ✅ |
| `img/w6s1_09.png` | 그림 1-13 | 고친 뒤 PWM 회로(402~421줄) | ✅ |
| `img/w6s1_10.png` | 그림 1-14 | 저장 후 `Packaging Steps`의 연필 표시 | ✅ |
| `img/w6s1_11.png` | 그림 1-15 | Merge 후 `Customization GUI` Preview — `led4[3:0]` | ✅ |
| `img/w6s1_12.png` | 그림 1-16 | IP Catalog 검색 `pwm` → `my_pwm_v1.0` | ✅ |

(선택) 1.6.3절 시뮬레이션을 해 보면 Tcl Console의 `OK` 여섯 줄이나 파형 창을 찍어 주면 그림으로 넣는다.

## 2교시 — [W6_S2_Vivado_ILA.md](W6_S2_Vivado_ILA.md) (제2장)

| 파일명 | 그림 | 담을 내용 | 상태 |
|---|---|---|---|
| `img/w6s2_01.png` | 그림 2-2 | Settings → IP → Repository — `ip_repo/my_pwm_1_0 (Project)` | ✅ |
| `img/w6s2_02.png` | 그림 2-3 | Add IP 검색 `pwm` → `my_pwm_v1.0` | ✅ |
| `img/w6s2_06.png` | 그림 2-4 | `my_pwm_0` 블록 — 오른쪽에 `led4[3:0]` | ✅ |
| `img/w6s2_03.png` | 그림 2-5 | (문제 상황) `led4`가 없는 `my_pwm_0` — 수정 전 버전 | ✅ |
| `img/w6s2_04.png` | 그림 2-6 | Run Connection Automation — `my_pwm_0/S00_AXI` | ✅ |
| `img/w6s2_07.png` | 그림 2-7 | Connection Automation 후 — Interconnect, Reset | ✅ |
| `img/w6s2_08.png` | 그림 2-8 | Make External — 바깥 포트 `led4[3:0]` | ✅ |
| `img/w6s2_09.png` | 그림 2-9 | Address Editor — `0x43C0_0000`, 64K | ✅ |
| `img/w6s2_10.png` | 그림 2-10 | Debug 표시 — `M00_AXI` 선과 `led4` 선 | ✅ |
| `img/w6s2_11.png` | 그림 2-11 | Debug용 Connection Automation — `ila_led4`, `ps7_0_axi_periph_M00_AXI` | ✅ |
| `img/w6s2_12.png` | 그림 2-12 | 완성된 Block Design(`system_ila_0` 포함) | ✅ |
| `img/w6s2_13.png` | 그림 2-14 | Constraints에 `cora_z7_07s_week06.xdc` | ✅ |
| `img/w6s2_14.png` | 그림 2-15 | 탐색기 `custom_pwm` — `design_1_wrapper.xsa`, `ip_upgrade.log` | ✅ |

`img/w6s2_05.png`(Connection Automation 후인데 `led4`가 없는 화면)는 그림 2-5와 같은 상황이라 본문에 넣지 않았다.

## 3교시 — [W6_S3_Vitis_PWM_ILA.md](W6_S3_Vitis_PWM_ILA.md) (제3장)

| 파일명 | 그림 | 담을 내용 | 상태 |
|---|---|---|---|
| `img/w6s3_01.png` | 그림 3-1 | `xparameters.h`의 `XPAR_MY_PWM_0_BASEADDR 0x43c00000` 줄 | 📷 대기 |
| `img/w6s3_02.png` | 그림 3-3 | PuTTY — `my_pwm start`, `duty 0 %` … `duty 100 %` | 📷 대기 |
| `img/w6s3_03.png` | 그림 3-5 | Hardware Manager — `.ltx` 지정 후 Waveform에 `ila_led4`, `slot_0` | 📷 대기 |
| `img/w6s3_04.png` | 그림 3-7 | **캡처 1** — `PERIOD = 200`, 트리거 `ila_led4` Rising. 펄스 5개. 가능하면 마커로 켜진 폭(50 또는 100)을 잰 모습 | 📷 대기 |
| `img/w6s3_05.png` | 그림 3-8 | **캡처 2** — 트리거 `AWADDR = 8` & `AWVALID = 1`, 위치 512. 트리거 앞뒤로 `ila_led4` 펄스 폭이 달라지는 모습, `WDATA` 값 | 📷 대기 |

## 캡처하면서 확인할 것

- 1.6.3절: `edit_my_pwm_v1_0`에 시뮬레이션 소스를 넣었다가 Re-Package 할 때 `File Groups`에 테스트벤치가 끼어드는지. 끼어들면 본문 안내(지우고 Merge)가 맞는지 확인한다.
- 3.3절: `ps7_init` 오류 때 `launch.json`에 잡힌 파일 이름이 정말 `my_pwm.tcl`인지.
- 3.5.3절: `ila_led4`의 Trigger `Value`에 `RRRR`을 넣을 수 있는지(4비트 프로브). 안 되면 `Radix`·입력 방식을 본문에 맞춰 고친다.
- 3.5.3절: 마커로 잰 켜진 폭이 정확히 `DUTY`(50 / 100 / 150)인지.
- 3.5.4절: 트리거 오른쪽에서 펄스 폭이 바뀌기까지 몇 샘플 걸리는지. 비교 기준은 쓴 다음 클럭부터 바뀌므로, 쓰는 순간 진행 중이던 주기의 폭이 이전 값과 새 값 사이로 한 번 어중간하게 나올 수 있다. 실제 캡처를 보고 본문 3.5.4절 표에 반영한다.

> **HEIC 주의.** 휴대폰 사진은 `.HEIC`로 저장되는 경우가 많고 GitHub·마크다운에서 보이지 않는다. 반드시 `.jpg`로 바꿔서 넣는다.
