/* =============================================================================
 * led_emio.c
 * Week 3, slot 2 (W3_S2) - blink RGB LED0's red channel through PS EMIO GPIO.
 *
 * Hardware side (Vivado, see W3_S2 6.2-6.5):
 *   ZYNQ7 Processing System, MIO Configuration -> EMIO GPIO Width = 1
 *   GPIO_0 interface -> Make External -> renamed "led_out"
 *   led_out_tri_io[0] -> package pin N15 (Cora Z7-07S RGB LED0, red channel), LVCMOS33
 *
 * No custom RTL / no PL logic anywhere - GPIO_0 is wired straight through
 * the PL fabric to the pin. This program is standalone (bare-metal), no OS.
 *
 * Kept as simple as possible: three fixed register addresses, no driver
 * instance, no xparameters.h. These are the real Zynq-7000 GPIO Bank 2
 * registers (Bank 2 = EMIO 0..31; our one EMIO bit is bit 0 of that bank;
 * base address 0xE000A000 on this board - see LAB02/README.md for how
 * these addresses were confirmed against the Xilinx driver source):
 *   DIRM_2 (direction, 1=output)      @ 0xE000A284
 *   OEN_2  (output buffer enable)     @ 0xE000A288
 *   DATA_2 (value: 1=LED ON, 0=OFF)   @ 0xE000A048
 *
 * This design only wires ONE EMIO bit, so writing a plain 0/1 (not a
 * read-modify-write) to these registers is safe - every other bit in the
 * bank is simply unused. If you ever add a second EMIO bit (e.g. the
 * homework: G channel), switch to read-modify-write so you don't clobber it.
 * ========================================================================== */

#include "xil_io.h"       /* Xil_Out32 */
#include "xil_printf.h"
#include "sleep.h"

#define DIRM_2   0xE000A284U   /* direction: 1 = output        */
#define OEN_2    0xE000A288U   /* output enable: 1 = on        */
#define DATA_2   0xE000A048U   /* value: 1 = LED ON, 0 = OFF   */

int main(void)
{
    Xil_Out32(DIRM_2, 1);   /* set as output */
    Xil_Out32(OEN_2,  1);   /* enable output */

    print("LED blink start\n\r");

    while (1) {
        Xil_Out32(DATA_2, 1);   /* LED ON */
        print("LED ON\n\r");
        usleep(500000);

        Xil_Out32(DATA_2, 0);   /* LED OFF */
        print("LED OFF\n\r");
        usleep(500000);
    }

    return 0;
}
