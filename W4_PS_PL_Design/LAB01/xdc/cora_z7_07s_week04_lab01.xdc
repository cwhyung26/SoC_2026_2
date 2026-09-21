## =========================================================================
## cora_z7_07s_week04_lab01.xdc
## Week 4, slot 1 (W4_S1) - Cora Z7-07S   [reference / answer key]
##
## Students assign these 5 pins by hand in I/O Planning (see W4_S1 7.x) -
## this file is the expected end result, not something to import.
##
## Port names below assume the AXI GPIO #1 external ports were named
## "btn" (channel 1, input, width 2) and "led0" (channel 2, output, width 3)
## at Make External time. The EXACT synthesized name (whether it stays
## "btn"/"led0" or gets a suffix like "_tri_i"/"_tri_o") must be confirmed
## in the I/O Ports table before assigning pins - do not assume this file
## is correct as-is; edit the port names to match what Vivado actually shows.
##
## Pin data: Digilent Cora-Z7-07S-Master.xdc
##   https://github.com/Digilent/digilent-xdc
## =========================================================================

## -------------------------------------------------------------------------
## Channel 1 (input) - BTN0/BTN1
##   btn[0] = BTN0 (D20), btn[1] = BTN1 (D19). Both active-high.
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D20  IOSTANDARD LVCMOS33 } [get_ports { btn[0] }];
set_property -dict { PACKAGE_PIN D19  IOSTANDARD LVCMOS33 } [get_ports { btn[1] }];

## -------------------------------------------------------------------------
## Channel 2 (output) - RGB LED0
##   led0[0] = R (N15), led0[1] = G (G17), led0[2] = B (L15)
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN N15  IOSTANDARD LVCMOS33 } [get_ports { led0[0] }];
set_property -dict { PACKAGE_PIN G17  IOSTANDARD LVCMOS33 } [get_ports { led0[1] }];
set_property -dict { PACKAGE_PIN L15  IOSTANDARD LVCMOS33 } [get_ports { led0[2] }];
