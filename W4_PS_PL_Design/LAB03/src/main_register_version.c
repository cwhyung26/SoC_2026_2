/* =============================================================================
 * main_register_version.c - W4 homework ANSWER (direct register version)
 *
 * !!! 배포 전 삭제 !!!  Solution file - see main.c.
 *
 * The homework lets students use either the XGpio driver or raw register
 * access ("여유가 있으면 두 가지로 다 짜서 비교해 본다"). This is the raw
 * version of the same program, for grading students who chose this route.
 *
 * The point of doing both: the offsets are SWAPPED versus chapter 7, because
 * the channels are swapped. Chapter 7 had the input on +0x0 and the output on
 * +0x8; here it is the other way round.
 *
 *   channel 1 = led4 (output)   GPIO_DATA  +0x0   GPIO_TRI  +0x4
 *   channel 2 = sw4  (input)    GPIO2_DATA +0x8   GPIO2_TRI +0xC
 *
 * That is exactly what XGpio_DiscreteRead/Write compute internally from the
 * channel number: base + (channel-1)*8 + 0.
 *
 * Note: only ONE main() may be in src/. Do not import this together with
 * main.c - the build fails with a duplicate main.
 * ========================================================================== */

#include "xparameters.h"
#include "xil_io.h"              /* Xil_In32 / Xil_Out32 */
#include "xil_printf.h"
#include <stdlib.h>              /* exit */

#define BASE        XPAR_AXI_GPIO_0_BASEADDR   /* 0x4120_0000 */

#define LED_DATA    (BASE + 0x0)   /* channel 1 = led4 */
#define LED_TRI     (BASE + 0x4)
#define SW_DATA     (BASE + 0x8)   /* channel 2 = sw4  */
#define SW_TRI      (BASE + 0xC)

int main(void)
{
    u32 sw;

    Xil_Out32(LED_TRI, 0x0);   /* led4: output (0 = output) */
    Xil_Out32(SW_TRI,  0xF);   /* sw4 : input  (1 = input)  */

    print("W4 homework start (register version) - turn all 4 switches on to quit\n\r");

    while (1) {
        sw = Xil_In32(SW_DATA) & 0xF;

        Xil_Out32(LED_DATA, sw);

        if (sw == 0xF) {
            xil_printf("all switches on (sw=0x%x) - exit\n\r", sw);
            exit(0);
        }
    }

    return 0;
}
