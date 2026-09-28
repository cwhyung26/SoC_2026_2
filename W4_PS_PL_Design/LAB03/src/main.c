/* =============================================================================
 * main.c - W4 homework ANSWER (XGpio driver version)
 *
 * !!! 배포 전 삭제 !!!  This file is the solution to homework step 9. Remove it
 * from the student repository before handing the homework out - W4_S2 step 8
 * requires students to write main.c themselves with New File.
 *
 * Hardware: the "homework" project (LAB03/build_homework_reference.tcl).
 * ONE AXI GPIO, and the channels are SWAPPED versus chapter 8:
 *   channel 1 = led4[3:0]  shield LEDs      (All Outputs)
 *   channel 2 = sw4[3:0]   shield switches  (All Inputs)
 *
 * Behaviour: copy sw4 to led4 forever; quit when all four switches are on.
 *
 * Note: only ONE main() may be in src/. If you also import
 * main_register_version.c, the build fails with a duplicate main - keep one
 * and delete or exclude the other.
 * ========================================================================== */

#include "xparameters.h"
#include "xgpio.h"
#include "xil_printf.h"
#include <stdlib.h>              /* exit */

#define GPIO_BASEADDR   XPAR_AXI_GPIO_0_BASEADDR

#define CH_LED   1               /* channel 1 = led4, output */
#define CH_SW    2               /* channel 2 = sw4,  input  */

int main(void)
{
    XGpio gpio;
    u32 sw;

    XGpio_Initialize(&gpio, GPIO_BASEADDR);

    /* AXI GPIO direction: 1 = input, 0 = output. Chapter 8 had these two the
     * other way round, because there channel 1 was the input.
     */
    XGpio_SetDataDirection(&gpio, CH_LED, 0x0);
    XGpio_SetDataDirection(&gpio, CH_SW,  0xF);

    print("W4 homework start - turn all 4 switches on to quit\n\r");

    while (1) {
        sw = XGpio_DiscreteRead(&gpio, CH_SW) & 0xF;

        /* Write the LEDs BEFORE testing the exit condition, so that the last
         * thing the LEDs show is 0xF. Test it first instead and the program
         * quits without ever displaying 0xF - that is the ordering question
         * the homework asks about.
         */
        XGpio_DiscreteWrite(&gpio, CH_LED, sw);

        if (sw == 0xF) {
            xil_printf("all switches on (sw=0x%x) - exit\n\r", sw);
            exit(0);
        }
    }

    return 0;
}
