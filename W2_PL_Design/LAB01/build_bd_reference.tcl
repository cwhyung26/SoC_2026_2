# build_bd_reference.tcl
# Reference build of the full W2_S1/W2_S2 Block Design (with System ILA),
# all the way to a bitstream.
#
# In class the students build the Block Design by hand (W2_S1) and then run
# synthesis / I/O Planning / bitstream (W2_S2). This script reproduces the
# SAME simplified design non-interactively and is what we use to check that
# the RTL + IP config + ILA actually go through synthesis, implementation
# and bitstream on Vivado 2023.2.
#
# Simplified design (matches W2_S1/W2_S2, 2026 rewrite):
#   - external ports : sys_clock , reset_rtl   (no aux button)
#   - Clocking Wizard: 125 -> 100 MHz, ACTIVE_HIGH reset, locked UNUSED
#   - NO Processor System Reset, NO Constant
#   - reset_rtl drives clk_wiz_0/reset AND pl_counter_0/rst directly
#     (this raises the expected [BD 41-1348] critical warning)
#   - System ILA : 3 native probes  count[4] / div_count[24] / tick[1]
#                  data depth 2048, capture control ON
#
# Usage:
#   cd <this LAB01 folder>
#   vivado -mode batch -source build_bd_reference.tcl
#   # optional: set env(W2_BUILD_DIR) to a SHORT local path first, e.g. C:/vw
#
# Output: <build dir>/project_w2_pl_bd/   (git-ignored)

set script_dir [file normalize [file dirname [info script]]]
set build_dir  $script_dir
if {[info exists ::env(W2_BUILD_DIR)] && $::env(W2_BUILD_DIR) ne ""} {
    set build_dir [file normalize $::env(W2_BUILD_DIR)]
    file mkdir $build_dir
}
set proj_name "project_w2_pl_bd"
set proj_dir  [file join $build_dir $proj_name]
if {[file exists $proj_dir]} { file delete -force $proj_dir }

create_project $proj_name $proj_dir -part xc7z007sclg400-1
if {[catch {set_property board_part digilentinc.com:cora-z7-07s:part0:1.1 [current_project]} err]} {
    set bp [lindex [get_board_parts -quiet *cora-z7-07s*] end]
    if {$bp ne ""} { set_property board_part $bp [current_project] }
}

# ---- sources ----
add_files -norecurse [list \
    [file join $script_dir rtl counter_n.v] \
    [file join $script_dir rtl pl_counter.v] ]
add_files -fileset constrs_1 -norecurse [file join $script_dir xdc cora_z7_07s_week02.xdc]
update_compile_order -fileset sources_1

# The class flow lets "Run Connection Automation" pull the 125 MHz clock pin
# (H16) + timing from the board file. This batch script has no GUI automation,
# so add that one clock constraint here (script-only).
set clk_xdc [file join $proj_dir "sys_clock_pin.xdc"]
set fh [open $clk_xdc w]
puts $fh {set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 } [get_ports { sys_clock }]}
puts $fh {create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sys_clock }]}
close $fh
add_files -fileset constrs_1 -norecurse $clk_xdc

# ---- block design ----
create_bd_design design_1

set clk_wiz [create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0]
set_property -dict [list \
    CONFIG.PRIM_SOURCE {Single_ended_clock_capable_pin} \
    CONFIG.PRIM_IN_FREQ {125.000} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.RESET_TYPE {ACTIVE_HIGH} \
    CONFIG.USE_LOCKED {true} \
] $clk_wiz

set pc [create_bd_cell -type module -reference pl_counter pl_counter_0]

# System ILA - native probe mode, 3 probes: count[4], div_count[24], tick[1]
set ila [create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0]
set_property -dict [list \
    CONFIG.C_MON_TYPE {NATIVE} \
    CONFIG.C_NUM_OF_PROBES {3} \
    CONFIG.C_PROBE0_WIDTH {4} \
    CONFIG.C_PROBE1_WIDTH {24} \
    CONFIG.C_PROBE2_WIDTH {1} \
    CONFIG.C_DATA_DEPTH {2048} \
    CONFIG.C_EN_STRG_QUAL {1} \
] $ila

# ---- external ports ----
create_bd_port -dir I -type clk -freq_hz 125000000 sys_clock
create_bd_port -dir I -type rst reset_rtl
set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports reset_rtl]

# ---- connections (simplified: button straight to both resets) ----
connect_bd_net [get_bd_ports sys_clock]         [get_bd_pins clk_wiz_0/clk_in1]
connect_bd_net [get_bd_ports reset_rtl]         [get_bd_pins clk_wiz_0/reset]
connect_bd_net [get_bd_ports reset_rtl]         [get_bd_pins pl_counter_0/rst]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins pl_counter_0/clk]
connect_bd_net [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins system_ila_0/clk]

connect_bd_net [get_bd_pins pl_counter_0/count]     [get_bd_pins system_ila_0/probe0]
connect_bd_net [get_bd_pins pl_counter_0/div_count] [get_bd_pins system_ila_0/probe1]
connect_bd_net [get_bd_pins pl_counter_0/tick]      [get_bd_pins system_ila_0/probe2]

regenerate_bd_layout
# [BD 41-1348] async-reset critical warning is EXPECTED here (see W2_S1 3.7).
validate_bd_design -quiet
save_bd_design

# ---- wrapper + run to bitstream ----
make_wrapper -files [get_files design_1.bd] -top
add_files -norecurse [file join $proj_dir "$proj_name.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v"]
set_property top design_1_wrapper [current_fileset]
update_compile_order -fileset sources_1

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

puts "==== RESULT ===="
puts "impl_1 status  : [get_property STATUS   [get_runs impl_1]]"
puts "impl_1 progress: [get_property PROGRESS [get_runs impl_1]]"
puts "WNS            : [get_property STATS.WNS [get_runs impl_1]]"
set bit [glob -nocomplain [file join $proj_dir "$proj_name.runs/impl_1/design_1_wrapper.bit"]]
set ltx [glob -nocomplain [file join $proj_dir "$proj_name.runs/impl_1/design_1_wrapper.ltx"]]
puts "bitstream      : $bit"
puts "probes (.ltx)  : $ltx"
