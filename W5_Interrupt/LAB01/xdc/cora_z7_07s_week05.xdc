
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
