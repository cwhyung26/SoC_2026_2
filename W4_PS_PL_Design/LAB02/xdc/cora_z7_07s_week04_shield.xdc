## =========================================================================
## cora_z7_07s_week04_shield.xdc
## Week 4, slot 2 (W4_S2) - Cora Z7-07S + Arduino/ChipKit shield
##
## THIS is the file students Import (Add Sources -> Add or create
## constraints -> Add Files) instead of assigning 8 pins by hand.
##
## Pin assignments are taken directly from ../../boards/board_summary.pdf
## (p.13-14, "Cora board with shield board").
##
## PORT NAMES assume you expand axi_gpio_1's GPIO / GPIO2 interfaces and
## Make External the *member signals* - gpio_io_i[3:0] and gpio2_io_o[3:0] -
## naming them "sw4" and "led4" (see W4_S2 8.2.3). Externalizing a member
## signal adds no suffix, so the top-level ports are exactly:
##   channel 1 (All Inputs)  gpio_io_i  -> sw4[3:0]
##   channel 2 (All Outputs) gpio2_io_o -> led4[3:0]
##
## If you instead Make External the whole *interface* (GPIO / GPIO2), as
## chapter 7 did for btn/led0, Vivado appends a suffix per member and the
## names become sw4_tri_i[3:0] / led4_tri_o[3:0] - then edit the names below
## to match. (board_summary.pdf's reference build lists sw4_tri_o, but that
## design configured the channel differently; an All Inputs channel's member
## is gpio_io_i, so it would be _tri_i here.)
##
## Always confirm the actual names in I/O Planning before trusting this file.
##
## Wiring on the shield breadboard (per board_summary.pdf p.13):
##   Led[3:0] -> shield digital pins 8,6,4,2
##   Sw[3:0]  -> shield digital pins 13,12,11,10
##   Don't forget the shield GND connection.
## =========================================================================

## -------------------------------------------------------------------------
## Channel 1 (input) - shield DIP switches, sw4[3:0]
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN U15  IOSTANDARD LVCMOS33 } [get_ports { sw4[0] }];
set_property -dict { PACKAGE_PIN K18  IOSTANDARD LVCMOS33 } [get_ports { sw4[1] }];
set_property -dict { PACKAGE_PIN J18  IOSTANDARD LVCMOS33 } [get_ports { sw4[2] }];
set_property -dict { PACKAGE_PIN G15  IOSTANDARD LVCMOS33 } [get_ports { sw4[3] }];

## -------------------------------------------------------------------------
## Channel 2 (output) - shield LEDs, led4[3:0]
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN T14  IOSTANDARD LVCMOS33 } [get_ports { led4[0] }];
set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports { led4[1] }];
set_property -dict { PACKAGE_PIN R17  IOSTANDARD LVCMOS33 } [get_ports { led4[2] }];
set_property -dict { PACKAGE_PIN N18  IOSTANDARD LVCMOS33 } [get_ports { led4[3] }];
