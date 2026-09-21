/* =============================================================================
 * btn_led_sw_driver.c
 * Week 4, slot 2 (W4_S2) - AXI GPIO #1 + #2, via the XGpio driver.
 *
 * Hardware (Vivado, see W4_S1 + W4_S2):
 *   AXI GPIO #1 (board, from W4_S1): ch1(in,2)=btn, ch2(out,3)=led0
 *   AXI GPIO #2 (shield, new in W4_S2): ch1(in,4)=shield switches,
 *                                        ch2(out,4)=shield LEDs
 *
 * This is the SAME behavior as W4_S1's btn_led_reg.c for GPIO #1, rewritten
 * with the XGpio driver instead of raw Xil_Out32/Xil_In32 - compare the two
 * files: the driver replaces "compute base+offset, shift/mask bits" with
 * named calls (XGpio_SetDataDirection, XGpio_DiscreteWrite/Read). GPIO #2
 * (shield) is added using the exact same four calls, just a different
 * XGpio instance.
 *
 * VERIFIED on the real lab02b platform (W4_S2 8.5.3): unlike W3's XGpioPs
 * case, no rework was needed here - XPAR_AXI_GPIO_0_BASEADDR /
 * XPAR_AXI_GPIO_1_BASEADDR are generated, and XGpio_Initialize() takes the
 * base address directly. Builds clean under this platform's SDT (-DSDT) flow.
 * ========================================================================== */

#include "xparameters.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "sleep.h"

/* Confirmed against the generated xparameters.h on lab02_platform. */
#define GPIO1_BASEADDR   XPAR_AXI_GPIO_0_BASEADDR   /* board:  btn / led0, 0x4120_0000 */
#define GPIO2_BASEADDR   XPAR_AXI_GPIO_1_BASEADDR   /* shield: sw4 / led4, 0x4121_0000 */

#define CH_IN    1
#define CH_OUT   2

int main(void)
{
    XGpio gpio1, gpio2;

    XGpio_Initialize(&gpio1, GPIO1_BASEADDR);
    XGpio_Initialize(&gpio2, GPIO2_BASEADDR);

    XGpio_SetDataDirection(&gpio1, CH_IN,  0x3);   /* btn:        input  */
    XGpio_SetDataDirection(&gpio1, CH_OUT, 0x0);   /* led0:       output */
    XGpio_SetDataDirection(&gpio2, CH_IN,  0xF);   /* shield sw:  input  */
    XGpio_SetDataDirection(&gpio2, CH_OUT, 0x0);   /* shield led: output */

    print("AXI GPIO driver demo start\n\r");

    while (1) {
        u32 btn = XGpio_DiscreteRead(&gpio1, CH_IN) & 0x3;
        u32 sw  = XGpio_DiscreteRead(&gpio2, CH_IN) & 0xF;

        XGpio_DiscreteWrite(&gpio1, CH_OUT, btn);   /* board LED  <- board BTN   */
        XGpio_DiscreteWrite(&gpio2, CH_OUT, sw);    /* shield LED <- shield SW  */

        xil_printf("btn=%d sw=%d\n\r", btn, sw);
        usleep(200000);
    }

    return 0;
}
