# W7 LAB03 — ILA로 인터럽트 보기 (Cora Z7-07S)

7주차 3교시(W7_S3) 실습 안내. 교재 본문은 [`../W7_S3_ILA_Interrupt.md`](../W7_S3_ILA_Interrupt.md)(제3장).

> **상태: 초안.** ILA 구성(슬롯·프로브·주소 폭)은 LAB01 배치 빌드의 `.ltx`로 확인했다. ILA 캡처는 아직 보드에서 하지 않았다.

## 새 파일이 없다

LAB01의 하드웨어(`gpio_irq`, System ILA 포함)와 `app_irq`(`../LAB01/src/sw_irq_counter.c`)를 그대로 쓴다. Vivado는 Hardware Manager만 연다.

- `Probes file`: `.../week7/vivado_prj/gpio_irq/gpio_irq.runs/impl_1/design_1_wrapper.ltx`
- `Program Device`는 누르지 않는다(Vitis `Run`이 이미 올렸다)

## ILA 신호와 주소

| 신호 | 폭 | 뜻 |
|---|---|---|
| `ila_sw4` | 4 | shield 스위치 (채널 1 입력) |
| `ila_irq` | 1 | `ip2intc_irpt` = pending |
| `slot_0` | — | `axi_gpio_0` 앞 AXI 버스, 주소 9비트 |

| 주소 | 레지스터 | 누가 |
|---|---|---|
| `000` | `GPIO_DATA` (`sw4`) | ISR의 `Xil_In32(GPIO_DATA)` |
| `008` | `GPIO2_DATA` (`led4`) | main의 `Xil_Out32(GPIO2_DATA, count)` |
| `120` | `IPISR` | ISR의 `Xil_Out32(GPIO_IPISR, Xil_In32(GPIO_IPISR))` (읽고 나서 쓴다) |

## 캡처 요약

| 캡처 | 설정 | 보이는 것 |
|---|---|---|
| 1. 인터럽트 한 번 | 트리거 `ila_irq` = `R`, 위치 128 | `ila_irq` ↑ → 읽기 `000` → 읽기·쓰기 `120` → `ila_irq` ↓ → 쓰기 `008` |
| 2. 바운스 세기 | 위와 같고 `Number of windows` 8, `Window data depth` 128, 창 안 위치 16 | 스위치 한 번에 창 여러 개 = 인터럽트 여러 번 |
| 3. clear를 빼면 | ISR의 `GPIO_IPISR` 쓰기 줄 주석, 트리거는 캡처 1과 같다 | `ila_irq`가 계속 1, 읽기 `000`만 반복, `120`·`008` 없음 |

- 캡처 1의 ① `ila_irq` ↑ → ② 첫 `ARVALID`까지의 샘플 수 × 20 ns가 인터럽트 반응 시간이다.
- 캡처 3 뒤에는 주석을 되돌리고 다시 `Build` → `Run`.
- 캡처 2가 끝나면 `Number of windows`를 1로 되돌린다.
