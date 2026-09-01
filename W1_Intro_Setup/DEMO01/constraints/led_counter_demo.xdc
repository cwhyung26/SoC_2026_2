## Cora Z7-07S (Rev. B) constraints for led_counter_demo
## Pin data taken from the Digilent Cora-Z7-07S-Master.xdc
##   https://github.com/Digilent/digilent-xdc
## Only the ports actually used by this design are constrained here.

## ---------------------------------------------------------------------------
## PL system clock - 125 MHz single-ended clock on the "sysclk" pin (H16)
## ---------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

## ---------------------------------------------------------------------------
## Reset - push-button BTN0 (D20)
## NOTE: the Cora push-buttons are ACTIVE-HIGH (pressed = 1), but this design's
## rst_n input is active-low. Wired straight through, the counter is held in
## reset while BTN0 is NOT pressed and runs while it IS pressed. Fixing that
## polarity (invert in the XDC-facing wrapper, or change the RTL) is a week-2
## topic - for now this is enough to give every port a real pin.
## ---------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS33 } [get_ports { rst_n }];

## ---------------------------------------------------------------------------
## LEDs - the Cora Z7-07S has NO plain LEDs, only two RGB LEDs (LD0, LD1),
## i.e. 6 controllable colour channels. The 4 counter bits are mapped onto
## 4 of those channels:
##   led[0] -> LD0 Blue   (L15)
##   led[1] -> LD0 Green  (G17)
##   led[2] -> LD0 Red    (N15)
##   led[3] -> LD1 Blue   (G14)
## So the counter value 0..15 shows up as colour combinations on LD0/LD1.
## ---------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { led[3] }];
