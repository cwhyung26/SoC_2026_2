/* =============================================================================
 * btn_led_reg.c
 * Week 4, slot 1 (W4_S1) - AXI GPIO #1, direct register access.
 *
 * Hardware (Vivado, see W4_S1 7.2-7.6):
 *   ZYNQ7 PS, M AXI GP0 enabled -> AXI Interconnect -> AXI GPIO #1
 *   Channel 1 (input,  width 2) -> btn[1:0]  = BTN0 (bit0), BTN1 (bit1)
 *   Channel 2 (output, width 3) -> led0[2:0] = R (bit0), G (bit1), B (bit2)
 *
 * AXI GPIO register map (Xilinx PG144 - fixed by the IP, same on every
 * board/instance):
 *   GPIO_DATA  (channel 1 data)      base + 0x0
 *   GPIO_TRI   (channel 1 direction) base + 0x4   (1 = input, 0 = output)
 *   GPIO2_DATA (channel 2 data)      base + 0x8
 *   GPIO2_TRI  (channel 2 direction) base + 0xC   (1 = input, 0 = output)
 *
 * NOTE THE POLARITY: for AXI GPIO, 1 = INPUT. This is the OPPOSITE of PS
 * GPIO's DIRM register from W3 (where 1 = output). Same vendor, different
 * IP, different convention - always check the register map, never assume
 * it matches the last IP you used.
 *
 * AXI_GPIO_BASEADDR must be confirmed in Vivado's Address Editor (Window
 * -> Address Editor, or in the Block Design). Confirmed on the real lab01
 * project (see W4_S1 7.4, Figure 7-11): 0x4120_0000. This is a common
 * default for the first AXI GPIO on M_AXI_GP0, but re-check it for any new
 * project - it is not guaranteed to repeat.
 * ========================================================================== */

#include "xil_io.h"
#include "xil_printf.h"
#include "sleep.h"

#define AXI_GPIO_BASEADDR   0x41200000U   /* confirmed via Address Editor, 7.4 */

#define GPIO_DATA    (AXI_GPIO_BASEADDR + 0x0)   /* channel 1: btn  (input)  */
#define GPIO_TRI     (AXI_GPIO_BASEADDR + 0x4)
#define GPIO2_DATA   (AXI_GPIO_BASEADDR + 0x8)   /* channel 2: led0 (output) */
#define GPIO2_TRI    (AXI_GPIO_BASEADDR + 0xC)

int main(void)
{
    u32 btn;

    Xil_Out32(GPIO_TRI,  0x3);   /* channel 1: bit0,bit1 = input  (1=input)  */
    Xil_Out32(GPIO2_TRI, 0x0);   /* channel 2: bit0..2   = output (0=output) */

    print("AXI GPIO #1 (register access) start\n\r");

    while (1) {
        btn = Xil_In32(GPIO_DATA) & 0x3;   /* bit0=BTN0, bit1=BTN1 */

        /* BTN0 -> LED red, BTN1 -> LED green, blue unused */
        Xil_Out32(GPIO2_DATA, btn);

        xil_printf("btn = %d\n\r", btn);
        usleep(200000);
    }

    return 0;
}
