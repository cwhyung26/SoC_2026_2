
#include "xparameters.h"
#include "xgpio.h"
#include "xinterrupt_wrap.h"   /* XSetupInterruptSystem */
#include "xil_printf.h"

XGpio gpio;

/* Shared between the ISR and main, so all three must be volatile. */
volatile int flag  = 0;   /* ISR sets this to say "an interrupt happened" */
volatile int count = 0;   /* 4-bit counter, 0..15 then wraps             */
volatile int sw    = 0;   /* switch value at the moment of the change    */

/* Runs automatically whenever sw4 changes. Keep it this short. */
void sw_isr(void *ref)
{
    sw    = XGpio_DiscreteRead(&gpio, 1);   /* channel 1 = sw4 */
    count = (count + 1) & 0xF;
    flag  = 1;

    XGpio_InterruptClear(&gpio, XGPIO_IR_CH1_MASK);   /* must clear */
}

int main(void)
{
    XGpio_Config *cfg;

    print("W5 LAB01: AXI GPIO interrupt start\n\r");

    XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_BASEADDR);
    XGpio_SetDataDirection(&gpio, 1, 0xF);   /* channel 1: input  (1=input)  */
    XGpio_SetDataDirection(&gpio, 2, 0x0);   /* channel 2: output (0=output) */

    /* Connect sw_isr to the GIC, then open the two interrupt gates. */
    cfg = XGpio_LookupConfig(XPAR_AXI_GPIO_0_BASEADDR);
    XSetupInterruptSystem(&gpio, (void *)sw_isr, cfg->IntrId, cfg->IntrParent,
                          XINTERRUPT_DEFAULT_PRIORITY);
    XGpio_InterruptEnable(&gpio, XGPIO_IR_CH1_MASK);   /* channel 1 */
    XGpio_InterruptGlobalEnable(&gpio);                /* whole IP  */

    while (1) {
        if (flag == 1) {
            flag = 0;
            XGpio_DiscreteWrite(&gpio, 2, count);   /* counter -> 4 LEDs */
            xil_printf("count = %2d, sw = %d\n\r", count, sw);
        }
    }

    return 0;
}
