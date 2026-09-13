/* =============================================================================
 * helloworld.c
 * Week 3, slot 1 (W3_S1) - PS-only "Hello World" (Cora Z7-07S).
 *
 * Hardware side (Vivado, see W3_S1 5.2-5.6):
 *   ZYNQ7 Processing System only, Run Block Automation -> Apply Board Preset.
 *   No PL logic at all - this program runs on the PS regardless of what (if
 *   anything) is in the PL fabric.
 *
 * This file is meant to be IMPORTED into a Vitis "Empty Application (C)"
 * component (see W3_S1 5.8), rather than generated from the built-in
 * "Hello World" template - so the exact source students build is the one
 * checked into this repo.
 *
 * NOTE: because we use "Empty Application" (not the Hello World template),
 * the template's companion platform.c/platform.h are NOT present, so this
 * file does not include platform.h or call init_platform()/cleanup_platform()
 * - print() alone (declared by xil_printf.h, part of the standalone BSP) is
 * enough for this lab.
 *
 * Output goes over UART 0 (MIO 14..15 on Cora Z7-07S, the same micro-USB
 * cable used for JTAG). View it with the Vitis Serial Terminal (default) or
 * PuTTY (115200 8N1) - see W3_S1 5.10.
 * ========================================================================== */

#include "xil_printf.h"

int main(void)
{
    print("Hello World\n\r");

    return 0;
}
