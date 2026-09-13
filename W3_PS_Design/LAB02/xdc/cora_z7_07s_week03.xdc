## =========================================================================
## cora_z7_07s_week03.xdc
## Week 3 PS lab - Cora Z7-07S   [reference / answer key]
##
## W3_S1 has NO pin constraints at all - the ZYNQ7 Processing System block
## is the only thing in the design (Block Automation handles DDR/FIXED_IO
## internally; no top-level fabric pin is touched).
##
## W3_S2 adds exactly one pin: the EMIO GPIO bit driving RGB LED0's red
## channel. Students create this from the GUI:
##   W3_S2 6.5  Layout -> I/O Planning : led_out_tri_io[0] -> pin N15, LVCMOS33
##   Ctrl+S -> Save Constraints -> my.xdc (or add to the existing one)
## This committed copy is the reference result of that step, confirmed on
## real hardware (2026-09-13).
##
## Pin data: Digilent Cora-Z7-07S-Master.xdc
##   https://github.com/Digilent/digilent-xdc
## =========================================================================

## -------------------------------------------------------------------------
## RGB LED0, red channel.
## Block Design: EMIO GPIO_0 interface (GPIO_I/GPIO_O/GPIO_T, width 1) ->
##   Make External, named "led_out" at the BD level.
## After synthesis this tri-state GPIO interface expands to a single
## top-level port named "led_out_tri_io[0]" (Vivado's naming convention for
## a Make-External'd inout/tri-state GPIO interface) - use THIS name in XDC,
## not "led_out".
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN N15  IOSTANDARD LVCMOS33 } [get_ports { led_out_tri_io[0] }];

## -------------------------------------------------------------------------
## For reference, the other RGB LED / button pins on Cora Z7-07S
## (not used in this lab - see W2_PL_Design for BTN0/BTN1 as PL reset):
##   LED0: R=N15 G=G17 B=L15
##   LED1: R=M15 G=L14 B=G14
##   BTN0: D20   BTN1: D19
## -------------------------------------------------------------------------
