## =========================================================================
## cora_z7_07s_week02.xdc
## Week 2 PL lab - Cora Z7-07S (Rev. B)   [reference / answer key]
##
## In class the students CREATE this file from the GUI:
##   W2_S2 4.2  Layout -> I/O Planning : reset_rtl -> pin D20, LVCMOS33
##   W2_S2 4.3  Ctrl+S -> Save Constraints -> new file "my.xdc"
## This committed copy is the reference result of that step.
##
## Only ONE input needs a manual constraint: the reset push-button.
## The 125 MHz clock (external port "sys_clock") is wired in the Block
## Design with "Run Connection Automation" to the board's sys_clock
## interface (W2_S1 3.5.4), so its package pin (H16) and 125 MHz timing
## come from the Cora board definition automatically - there is no
## create_clock / PACKAGE_PIN line for it here.
##
## Pin data: Digilent Cora-Z7-07S-Master.xdc
##   https://github.com/Digilent/digilent-xdc
## =========================================================================

## -------------------------------------------------------------------------
## Reset push-button  BTN0  (ACTIVE-HIGH: pressed = 1)
##   External BD port name: reset_rtl  (created by Connection Automation)
##   Drives clk_wiz_0/reset and pl_counter_0/rst together.
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D20  IOSTANDARD LVCMOS33 } [get_ports { reset_rtl }];

## -------------------------------------------------------------------------
## Vivado also appends the debug-hub (dbg_hub) properties to my.xdc after
## the System ILA is in the design, e.g.
##   set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
##   set_property C_ENABLE_CLK_DIVIDER false     [get_debug_cores dbg_hub]
##   set_property C_USER_SCAN_CHAIN 1            [get_debug_cores dbg_hub]
##   connect_debug_port dbg_hub/clk [get_nets clk]
## Those are generated automatically - do not hand-edit or delete them.
## -------------------------------------------------------------------------

## -------------------------------------------------------------------------
## Optional: if you did NOT use board automation for the clock, rename the
## BD clock port to sys_clock and constrain it by hand instead:
##   set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports { sys_clock }];
##   create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sys_clock }];
## -------------------------------------------------------------------------

## BTN1 (D19) is unused in this simplified design.
