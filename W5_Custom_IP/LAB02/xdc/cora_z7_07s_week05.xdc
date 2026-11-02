## =========================================================================
## cora_z7_07s_week05.xdc
## Week 5 - Cora Z7-07S + Arduino/ChipKit shield, custom IP my_io
##
## The four ports below are the my_io pins made external in the block
## design (W5_S2 2.3). Externalizing a plain pin (not an interface) adds no
## suffix, but Vivado appends "_0" - rename the ports to exactly these names:
##   led4[3:0]  shield LEDs       (my_io +0x0, write)
##   led3[2:0]  RGB LED1          (my_io +0x4, write)
##   sw4[3:0]   shield switches   (my_io +0x8, read)
##   btn2[1:0]  BTN0, BTN1        (my_io +0xC, read)
##
## Pins are the same as week 4 / the midterm (board_summary.pdf p.13-14).
## Wiring on the shield breadboard:
##   led4[0..3] -> shield digital pins 2, 4, 6, 8
##   sw4[0..3]  -> shield digital pins 10, 11, 12, 13
##   Don't forget the shield GND connection.
## =========================================================================

## sw4[3:0] - shield switches (CK_IO10..13)
set_property -dict { PACKAGE_PIN U15  IOSTANDARD LVCMOS33 } [get_ports { sw4[0] }];
set_property -dict { PACKAGE_PIN K18  IOSTANDARD LVCMOS33 } [get_ports { sw4[1] }];
set_property -dict { PACKAGE_PIN J18  IOSTANDARD LVCMOS33 } [get_ports { sw4[2] }];
set_property -dict { PACKAGE_PIN G15  IOSTANDARD LVCMOS33 } [get_ports { sw4[3] }];

## led4[3:0] - shield LEDs (CK_IO2, 4, 6, 8)
set_property -dict { PACKAGE_PIN T14  IOSTANDARD LVCMOS33 } [get_ports { led4[0] }];
set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports { led4[1] }];
set_property -dict { PACKAGE_PIN R17  IOSTANDARD LVCMOS33 } [get_ports { led4[2] }];
set_property -dict { PACKAGE_PIN N18  IOSTANDARD LVCMOS33 } [get_ports { led4[3] }];

## btn2[1:0] - BTN0, BTN1
set_property -dict { PACKAGE_PIN D20  IOSTANDARD LVCMOS33 } [get_ports { btn2[0] }];
set_property -dict { PACKAGE_PIN D19  IOSTANDARD LVCMOS33 } [get_ports { btn2[1] }];

## led3[2:0] - RGB LED1 (R, G, B)
set_property -dict { PACKAGE_PIN M15  IOSTANDARD LVCMOS33 } [get_ports { led3[0] }];
set_property -dict { PACKAGE_PIN L14  IOSTANDARD LVCMOS33 } [get_ports { led3[1] }];
set_property -dict { PACKAGE_PIN G14  IOSTANDARD LVCMOS33 } [get_ports { led3[2] }];
