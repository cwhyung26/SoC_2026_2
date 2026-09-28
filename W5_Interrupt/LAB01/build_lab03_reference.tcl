# build_lab03_reference.tcl
# Reference build of the week 5 hardware (Vivado project "lab03") on the
# Cora Z7-07S, from an empty project all the way to a bitstream and an .xsa.
#
# In class the students build this project BY HAND (W5_S1 1.3 - 1.7) - that is
# the practice. This script is not the lab; it exists for two other reasons:
#   - to check that the design really goes through synthesis, implementation,
#     bitstream and XSA export on Vivado 2023.2
#   - as a recovery path when a student's project is broken or lost and there
#     is no time to rebuild it during class
#
# The design it builds:
#   ZYNQ7 PS, M_AXI_GP0 on, Fabric Interrupts (IRQ_F2P) on
#     -> AXI Interconnect (ps7_0_axi_periph) -> ONE AXI GPIO, two channels
#   axi_gpio_0  ch1 All Inputs  w4 -> sw4[3:0]   shield switches
#               ch2 All Outputs w4 -> led4[3:0]  shield LEDs
#               C_INTERRUPT_PRESENT -> ip2intc_irpt -> PS IRQ_F2P[0:0]
#   Expected address: axi_gpio_0 at 0x4120_0000, range 64K (one slave only)
#
# The GPIO member signals (gpio_io_i / gpio2_io_o) are externalised, not the
# GPIO / GPIO2 interfaces, so the top-level ports come out as sw4[3:0] and
# led4[3:0] with no _tri_i / _tri_o suffix. That is what
# xdc/cora_z7_07s_week05.xdc expects.
#
# Usage:
#   cd <the LAB01 folder that holds this file>
#   vivado -mode batch -source build_lab03_reference.tcl
#   # optional, and recommended: choose a SHORT ASCII build path first
#   #   set env(W5_BUILD_DIR) C:/vw5        (Vivado GUI Tcl console)
#   #   set W5_BUILD_DIR=C:/vw5            (Windows cmd, before launching)
#
# Output: <build dir>/lab03/ , including
#   lab03/lab03.runs/impl_1/design_1_wrapper.bit
#   lab03/design_1_wrapper.xsa     <- this is what Vitis needs (W5_S1 1.8)
#
# STATUS: draft, not yet run on Vivado 2023.2.
# =========================================================================

set script_dir [file normalize [file dirname [info script]]]

# ---- where to build -----------------------------------------------------
# Vivado is unhappy with long paths and with non-ASCII characters in them.
# This repo often sits under a Korean folder name (...\문서\GitHub\...), so
# fall back to a short ASCII path automatically in that case.
set build_dir $script_dir
if {[info exists ::env(W5_BUILD_DIR)] && $::env(W5_BUILD_DIR) ne ""} {
    set build_dir [file normalize $::env(W5_BUILD_DIR)]
    puts "Build directory from W5_BUILD_DIR: $build_dir"
} elseif {![regexp {^[ -~]*$} $script_dir]} {
    set build_dir "C:/vivado_w5"
    puts "NOTE: this script's path contains non-ASCII characters:"
    puts "        $script_dir"
    puts "      Vivado can fail on such paths, so building in $build_dir instead."
    puts "      Set W5_BUILD_DIR to choose a different location."
}
file mkdir $build_dir

set proj_name "lab03"
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

# Same constraints file the students Import in W5_S1 1.7.
add_files -fileset constrs_1 -norecurse \
    [file join $script_dir xdc cora_z7_07s_week05.xdc]

# ---- block design -------------------------------------------------------
create_bd_design design_1

# ZYNQ7 PS with the board preset (= Run Block Automation in the GUI).
set ps [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 \
            processing_system7_0]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
    -config {make_external "FIXED_IO, DDR" apply_board_preset "1" \
             Master "Disable" Slave "Disable"} $ps

# The two PS switches the students turn on by hand:
#   PCW_USE_M_AXI_GP0                           -> W5_S1 1.4 (AXI master)
#   PCW_USE_FABRIC_INTERRUPT + PCW_IRQ_F2P_INTR -> W5_S1 1.6 (IRQ_F2P input)
set_property -dict [list \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
    CONFIG.PCW_IRQ_F2P_INTR {1} \
] $ps

# One AXI GPIO, dual channel, with the interrupt output enabled.
#   C_ALL_INPUTS    / C_GPIO_WIDTH  -> channel 1 = sw4  (4 inputs)
#   C_ALL_OUTPUTS_2 / C_GPIO2_WIDTH -> channel 2 = led4 (4 outputs)
#   C_INTERRUPT_PRESENT             -> "Enable Interrupt" (W5_S1 1.5)
set gpio [create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0]
set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_GPIO_WIDTH {4} \
    CONFIG.C_IS_DUAL {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {4} \
    CONFIG.C_INTERRUPT_PRESENT {1} \
] $gpio

# S_AXI only - this also creates the AXI Interconnect and the Processor
# System Reset, exactly as Run Connection Automation does in the GUI.
apply_bd_automation -rule xilinx.com:bd_rule:axi4 \
    -config {Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} \
             Master {/processing_system7_0/M_AXI_GP0} \
             Slave {/axi_gpio_0/S_AXI} ddr_seg {Auto} \
             intc_ip {New AXI Interconnect} master_apm {0}} \
    [get_bd_intf_pins axi_gpio_0/S_AXI]

# External ports from the MEMBER SIGNALS, so no suffix is added (W5_S1 1.5).
make_bd_pins_external -name sw4  [get_bd_pins axi_gpio_0/gpio_io_i]
make_bd_pins_external -name led4 [get_bd_pins axi_gpio_0/gpio2_io_o]

# The interrupt line: one wire from the PL into the PS (W5_S1 1.6).
connect_bd_net [get_bd_pins axi_gpio_0/ip2intc_irpt] \
               [get_bd_pins processing_system7_0/IRQ_F2P]

assign_bd_address
regenerate_bd_layout
validate_bd_design
save_bd_design

puts ""
puts "==== ADDRESSES (compare with the Address Editor, W5_S1 1.6) ===="
# Expected: one line, axi_gpio_0 at 0x4120_0000, range 64K. If yours differs,
# the C code still works - it uses XPAR_AXI_GPIO_0_BASEADDR, not a literal.
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

# Print the real top-level port names. If the XDC and these disagree,
# synthesis warns "no ports matched" - this is where to look first.
puts ""
puts "==== TOP-LEVEL PORTS (must match xdc/cora_z7_07s_week05.xdc) ===="
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

# ---- export hardware, bitstream included (= Export Hardware in the GUI) --
open_run impl_1
set xsa [file join $proj_dir design_1_wrapper.xsa]
write_hw_platform -fixed -include_bit -force -file $xsa

set bit [file join $proj_dir $proj_name.runs impl_1 design_1_wrapper.bit]
puts ""
puts "bitstream : $bit"
puts "XSA       : $xsa"
puts ""
puts "Next (W5_S1 1.8): in Vitis create platform w5_platform from this .xsa,"
puts "                  build it, then check that xparameters.h says"
puts "                  XPAR_AXI_GPIO_0_INTERRUPT_PRESENT 0x1"
puts "                  Application lab01_app -> src/sw_irq_counter.c"
puts "                  Application lab02_app -> ../LAB02/src/timer_scheduler.c"
