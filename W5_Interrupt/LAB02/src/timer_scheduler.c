
#include "xparameters.h"
#include "xscutimer.h"
#include "xgpio.h"
#include "xinterrupt_wrap.h"   /* XSetupInterruptSystem */
#include "xil_printf.h"

#define LOAD_1MS   324999      /* 325 MHz / 1000 - 1, see the note above */

#define SW_BITS    0x7         /* led4[2:0] follow the switches */
#define BEAT_BIT   0x8         /* led4[3] is the heartbeat      */

XScuTimer timer;
XGpio gpio;

volatile int tick = 0;         /* +1 every 1 ms, and nothing else */

/* Runs 1000 times a second. Never put xil_printf() here - see W5_S2 2.8. */
void timer_isr(void *ref)
{
    XScuTimer_ClearInterruptStatus(&timer);   /* must clear */
    tick = tick + 1;
}

int main(void)
{
    XScuTimer_Config *cfg;
    int t50 = 0, t500 = 0, t1000 = 0;   /* tick at which each job last ran */
    int led = 0;                        /* what the 4 shield LEDs show now */
    int sw = 0;

    print("W5 LAB02: 1 ms tick scheduler start\n\r");

    XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_BASEADDR);
    XGpio_SetDataDirection(&gpio, 1, 0xF);   /* sw4  : input  */
    XGpio_SetDataDirection(&gpio, 2, 0x0);   /* led4 : output */
    XGpio_DiscreteWrite(&gpio, 2, 0x0);

    /* Connect timer_isr to the GIC first, then set the period and start. */
    cfg = XScuTimer_LookupConfig(XPAR_XSCUTIMER_0_BASEADDR);
    XScuTimer_CfgInitialize(&timer, cfg, cfg->BaseAddr);
    XSetupInterruptSystem(&timer, (void *)timer_isr, cfg->IntrId,
                          cfg->IntrParent, XINTERRUPT_DEFAULT_PRIORITY);

    XScuTimer_SetPrescaler(&timer, 0);    /* count at the full 325 MHz */
    XScuTimer_LoadTimer(&timer, LOAD_1MS);
    XScuTimer_EnableAutoReload(&timer);   /* without this: only one tick */
    XScuTimer_EnableInterrupt(&timer);
    XScuTimer_Start(&timer);

    while (1) {
        /* job 1, every 50 ms: sw4[2:0] -> led4[2:0], heartbeat bit kept */
        if (tick - t50 >= 50) {
            t50 = tick;
            sw  = XGpio_DiscreteRead(&gpio, 1);
            led = (led & BEAT_BIT) | (sw & SW_BITS);
            XGpio_DiscreteWrite(&gpio, 2, led);
        }

        /* job 2, every 500 ms: toggle led4[3], switch bits kept */
        if (tick - t500 >= 500) {
            t500 = tick;
            led = led ^ BEAT_BIT;
            XGpio_DiscreteWrite(&gpio, 2, led);
        }

        /* job 3, every 1000 ms: one status line */
        if (tick - t1000 >= 1000) {
            t1000 = tick;
            xil_printf("t = %d s, sw = %d\n\r", tick / 1000, sw);
        }
    }

    return 0;
}
