## =========================================================================
## cora_z7_07s_week06.xdc
## Week 6 - Cora Z7-07S + Arduino/ChipKit shield, custom IP my_pwm
##
## The only port is the my_pwm output made external in the block design
## (W6_S2 2.3). Vivado appends "_0" - rename the port to exactly this name:
##   led4[3:0]  shield LEDs x4  (my_pwm PWM output, all four the same)
##
## Pins are the same as week 4/5 and the midterm (board_summary.pdf p.13-14).
## Wiring on the shield breadboard:
##   led4[0..3] -> shield digital pins 2, 4, 6, 8
##   Don't forget the shield GND connection.
## =========================================================================

## led4[3:0] - shield LEDs (CK_IO2, 4, 6, 8)
set_property -dict { PACKAGE_PIN T14  IOSTANDARD LVCMOS33 } [get_ports { led4[0] }];
set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports { led4[1] }];
set_property -dict { PACKAGE_PIN R17  IOSTANDARD LVCMOS33 } [get_ports { led4[2] }];
set_property -dict { PACKAGE_PIN N18  IOSTANDARD LVCMOS33 } [get_ports { led4[3] }];
