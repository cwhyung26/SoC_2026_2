#include "xparameters.h"
#include "xil_io.h"
#include "xinterrupt_wrap.h"   /* XSetupInterruptSystem */
#include "xil_printf.h"

/* AXI GPIO 채널 2 = shield LED 4개 - 1장과 같다 */
#define GPIO2_DATA   (XPAR_AXI_GPIO_0_BASEADDR + 0x008)

/* Cortex-A9 Private Timer - 2장 2.5절 */
#define TIMER_BASE   XPAR_XSCUTIMER_0_BASEADDR   /* 0xF8F0_0600 */
#define TIMER_LOAD   (TIMER_BASE + 0x0)    /* 여기서부터 0까지 센다                    */
#define TIMER_CTRL   (TIMER_BASE + 0x8)    /* bit0 시작, bit1 auto-reload, bit2 인터럽트 */
#define TIMER_ISR    (TIMER_BASE + 0xC)    /* bit0 = 만료 표시. 1을 써서 지운다         */

#define LOAD_1MS     324999                /* (650 MHz CPU / 2) / 1000 - 1, 2.3절 */

#define LED_50       0x1                   /* led4[0] : 50 ms 마다 토글   */
#define LED_500      0x2                   /* led4[1] : 500 ms 마다 토글  */
#define LED_1000     0x4                   /* led4[2] : 1000 ms 마다 토글 */

volatile int tick = 0;                     /* 1 ms 마다 +1, 그 외에는 아무것도 안 한다 */

/* 1초에 1000번 불린다. 여기에 xil_printf 를 넣지 않는다 - 2.8절 */
void timer_isr(void *ref)
{
    Xil_Out32(TIMER_ISR, 0x1);             /* 만료 표시 지우기 - 꼭 한다 */
    tick = tick + 1;
}

int main(void)
{
    int t50 = 0, t500 = 0, t1000 = 0;      /* 각 작업이 마지막으로 실행된 tick */
    int led = 0;                           /* 지금 LED 4개가 보여 주는 값      */

    print("W7 LAB02: 1 ms tick scheduler start\n\r");

    Xil_Out32(GPIO2_DATA, 0x0);

    XSetupInterruptSystem(NULL, (void *)timer_isr,   /* (1) "타이머 인터럽트가 오면 timer_isr" */
                          XPAR_XSCUTIMER_0_INTERRUPTS,
                          XPAR_XSCUTIMER_0_INTERRUPT_PARENT,
                          XINTERRUPT_DEFAULT_PRIORITY);

    Xil_Out32(TIMER_LOAD, LOAD_1MS);       /* (2) 1 ms 주기                     */
    Xil_Out32(TIMER_CTRL, 0x7);            /* (3) 인터럽트 + auto-reload + 시작 */

    while (1) {
        /* 작업 1, 50 ms 마다: led4[0] 토글 */
        if (tick - t50 >= 50) {
            t50 = tick;
            led = led ^ LED_50;
            Xil_Out32(GPIO2_DATA, led);
        }

        /* 작업 2, 500 ms 마다: led4[1] 토글 */
        if (tick - t500 >= 500) {
            t500 = tick;
            led = led ^ LED_500;
            Xil_Out32(GPIO2_DATA, led);
        }

        /* 작업 3, 1000 ms 마다: led4[2] 토글 + 상태 한 줄 */
        if (tick - t1000 >= 1000) {
            t1000 = tick;
            led = led ^ LED_1000;
            Xil_Out32(GPIO2_DATA, led);
            xil_printf("t = %d s\n\r", tick / 1000);
        }
    }

    return 0;
}
