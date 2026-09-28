# build_homework_reference.tcl
# Reference build of the week 4 HOMEWORK hardware (Vivado project "homework")
# on the Cora Z7-07S, from an empty project to a bitstream and an .xsa.
#
# This is the answer to the Vivado half of the homework (W4_S2, 과제 steps 1-5).
# The students are supposed to build it themselves. Use this script to:
#   - verify the design builds on Vivado 2023.2
#   - grade: compare a student's project against a known-good one
#   - unblock someone who could not finish the Vivado part, so they can still
#     do the software part (writing main.c), which is where the real learning is
#
# The software half is NOT here on purpose. The homework says main.c must be
# written from scratch with New File (step 8), so handing out a main.c would
# remove the exercise. README.md lists what main.c has to do and the two
# numbers students most often get wrong.
#
# The design (note the channels are SWAPPED versus chapter 8):
#   ZYNQ7 PS with the board preset, M_AXI_GP0 enabled
#     -> AXI Interconnect (ps7_0_axi_periph) -> ONE AXI GPIO, two channels
#   axi_gpio_0  ch1 All OUTPUTS w4 -> led4[3:0]  shield LEDs
#               ch2 All INPUTS  w4 -> sw4[3:0]   shield switches
#   Expected address: axi_gpio_0 at 0x4120_0000, range 64K
#   No interrupt (that is week 5).
#
# Chapter 8 had ch1 = inputs (sw4) and ch2 = outputs (led4). Here it is the
# other way round, which is the whole point of the homework: the channel
# number does not decide the direction - you do. Two consequences:
#   - the IP parameters swap: C_ALL_OUTPUTS (ch1) + C_ALL_INPUTS_2 (ch2)
#   - the live member signal of each channel swaps too, so the pins we
#     externalise are gpio_io_o (ch1 output) and gpio2_io_i (ch2 input) -
#     chapter 8 externalised gpio_io_i and gpio2_io_o
#
# And yet the XDC does not change. The external port NAMES we give are still
# led4 and sw4, and the shield pins are the same, so this script reuses
# ../LAB02/xdc/cora_z7_07s_week04_shield.xdc untouched - that is homework
# step 4, and the thing students are asked to explain.
#
# Usage:
#   cd <the LAB03 folder that holds this file>
#   vivado -mode batch -source build_homework_reference.tcl
#   # optional, and recommended: choose a SHORT ASCII build path first
#   #   set env(W4_BUILD_DIR) C:/vw4        (Vivado GUI Tcl console)
#   #   set W4_BUILD_DIR=C:/vw4            (Windows cmd, before launching)
#
# Output: <build dir>/homework/ , including
#   homework/homework.runs/impl_1/design_1_wrapper.bit
#   homework/design_1_wrapper.xsa    <- homework step 6 needs this
#
# STATUS: draft, not yet run on Vivado 2023.2.
# =========================================================================

set script_dir [file normalize [file dirname [info script]]]

# ---- where to build -----------------------------------------------------
# Vivado is unhappy with long paths and with non-ASCII characters in them.
# This repo often sits under a Korean folder name (...\문서\GitHub\...), so
# fall back to a short ASCII path automatically in that case.
set build_dir $script_dir
if {[info exists ::env(W4_BUILD_DIR)] && $::env(W4_BUILD_DIR) ne ""} {
    set build_dir [file normalize $::env(W4_BUILD_DIR)]
    puts "Build directory from W4_BUILD_DIR: $build_dir"
} elseif {![regexp {^[ -~]*$} $script_dir]} {
    set build_dir "C:/vivado_w4"
    puts "NOTE: this script's path contains non-ASCII characters:"
    puts "        $script_dir"
    puts "      Vivado can fail on such paths, so building in $build_dir instead."
    puts "      Set W4_BUILD_DIR to choose a different location."
}
file mkdir $build_dir

set proj_name "homework"
set proj_dir  [file join $build_dir $proj_name]
if {[file exists $proj_dir]} {
    puts "Removing existing $proj_dir and recreating it."
    file delete -force $proj_dir
}

# ---- project ------------------------------------------------------------
create_project $proj_name $proj_dir -part xc7z007sclg400-1

if {[catch {set_property board_part digilentinc.com:cora-z7-07s:part0:1.1 [current_project]} err]} {
    puts "board_part 1.1 failed ($err) - looking for the newest installed version."
    set bp [lindex [get_board_parts -quiet *cora-z7-07s*] end]
    if {$bp ne ""} {
        set_property board_part $bp [current_project]
        puts "board_part set to $bp."
    } else {
        puts "ERROR: cora-z7-07s board file not found. Install it first (W1_S2 2.2)."
        puts "       The board preset is required for the PS DDR/MIO settings."
        return -code error "missing cora-z7-07s board file"
    }
}

# Homework step 4: the SAME constraints file chapter 8 imported, unedited.
set shield_xdc [file join $script_dir .. LAB02 xdc cora_z7_07s_week04_shield.xdc]
if {![file exists $shield_xdc]} {
    puts "ERROR: cannot find $shield_xdc"
    return -code error "missing shield xdc"
}
add_files -fileset constrs_1 -norecurse $shield_xdc
puts "Constraints: [file normalize $shield_xdc]"

# ---- block design -------------------------------------------------------
create_bd_design design_1

# ZYNQ7 PS with the board preset (= Run Block Automation in the GUI).
set ps [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 \
            processing_system7_0]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
    -config {make_external "FIXED_IO, DDR" apply_board_preset "1" \
             Master "Disable" Slave "Disable"} $ps

# Homework step 1: M AXI GP0 on. Fabric interrupts stay off.
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1}] $ps

# Homework step 2: one AXI GPIO, dual channel, channels SWAPPED vs chapter 8.
#   ch1 -> C_ALL_OUTPUTS   + C_GPIO_WIDTH  = 4   (led4)
#   ch2 -> C_ALL_INPUTS_2  + C_GPIO2_WIDTH = 4   (sw4)
set gpio [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0]
set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {4} \
    CONFIG.C_IS_DUAL {1} \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {4} \
] $gpio

# S_AXI only - also creates the AXI Interconnect and Processor System Reset.
apply_bd_automation -rule xilinx.com:bd_rule:axi4 \
    -config {Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} \
             Master {/processing_system7_0/M_AXI_GP0} \
             Slave {/axi_gpio_0/S_AXI} ddr_seg {Auto} \
             intc_ip {New AXI Interconnect} master_apm {0}} \
    [get_bd_intf_pins axi_gpio_0/S_AXI]

# Homework step 3: externalise the MEMBER SIGNALS, so no suffix is added.
# Which member is live follows the direction, so these names differ from
# chapter 8 - but the external port names stay led4 / sw4, which is why the
# XDC above needs no edit.
#   ch1 is All Outputs -> the live member is gpio_io_o
#   ch2 is All Inputs  -> the live member is gpio2_io_i
make_bd_pins_external -name led4 [get_bd_pins axi_gpio_0/gpio_io_o]
make_bd_pins_external -name sw4  [get_bd_pins axi_gpio_0/gpio2_io_i]

assign_bd_address
regenerate_bd_layout
validate_bd_design
save_bd_design

puts ""
puts "==== ADDRESSES ===="
# Expected: one line, axi_gpio_0 at 0x4120_0000, range 64K.
# If a student writes main.c with raw addresses, led4 is +0x0 and sw4 is +0x8
# here - the opposite of chapter 8.
set ps_space [get_bd_addr_spaces -quiet processing_system7_0/Data]
foreach seg [get_bd_addr_segs -quiet -of_objects $ps_space] {
    puts [format "  %-46s offset %s  range %s" \
              $seg [get_property -quiet OFFSET $seg] \
              [get_property -quiet RANGE $seg]]
}

# ---- wrapper ------------------------------------------------------------
make_wrapper -files [get_files design_1.bd] -top
add_files -norecurse \
    [file join $proj_dir "$proj_name.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v"]
set_property top design_1_wrapper [current_fileset]
update_compile_order -fileset sources_1

# Must print exactly led4 and sw4 - no _tri_o / _tri_i suffix. If a suffix
# shows up, an interface was externalised instead of a member signal, and the
# shield XDC will not match (synthesis: "no ports matched").
puts ""
puts "==== TOP-LEVEL PORTS (must be led4 and sw4, no suffix) ===="
foreach p [lsort [get_bd_ports -quiet]] {
    puts "  BD port : $p"
}
foreach p [lsort [get_bd_intf_ports -quiet]] {
    puts "  BD intf : $p"
}

# ---- synthesis, implementation, bitstream --------------------------------
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

puts ""
puts "==== RESULT ===="
puts "impl_1 status  : [get_property STATUS   [get_runs impl_1]]"
puts "impl_1 progress: [get_property PROGRESS [get_runs impl_1]]"
puts "WNS            : [get_property STATS.WNS [get_runs impl_1]]"

if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    puts "ERROR: implementation did not finish - no .xsa written."
    return -code error "impl_1 incomplete"
}

# ---- export hardware, bitstream included --------------------------------
open_run impl_1
set xsa [file join $proj_dir design_1_wrapper.xsa]
write_hw_platform -fixed -include_bit -force -file $xsa

set bit [file join $proj_dir $proj_name.runs impl_1 design_1_wrapper.bit]
puts ""
puts "bitstream : $bit"
puts "XSA       : $xsa"
puts ""
puts "Next (homework steps 6-10): in Vitis create platform homework_platform"
puts "  from this .xsa, build it, create Empty Application homework_app, then"
puts "  write src/main.c BY HAND (New File - do not import). See LAB03/README.md"
puts "  for what it has to do."
