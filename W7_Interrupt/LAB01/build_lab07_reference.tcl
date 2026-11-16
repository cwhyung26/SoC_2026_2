# =============================================================================
# build_lab07_reference.tcl - W7 reference build (AXI GPIO interrupt + System ILA)
#
#   vivado -mode batch -source build_lab07_reference.tcl
#
# Builds, from nothing, the same result as chapter 1 done by hand:
#   1. project gpio_irq: ZYNQ7 PS (M_AXI_GP0 + IRQ_F2P) + axi_gpio_0
#      (ch1 = 4 inputs, ch2 = 4 outputs, Enable Interrupt)
#   2. Connection Automation (S_AXI only), member signals made external as
#      sw4 / led4, ip2intc_irpt -> IRQ_F2P, nets renamed ila_sw4 / ila_irq
#   3. Debug on the axi_gpio_0/S_AXI bus, ila_sw4 and ila_irq -> System ILA
#   4. xdc, bitstream (+ .ltx), design_1_wrapper.xsa (bitstream included)
#
# Vivado fails on non-ASCII or long paths. If this script sits under such a
# path (the course repo is under ...\문서\GitHub\...), it builds in
# C:/vivado_w7 instead. Set W7_BUILD_DIR to use another location.
# Run it from PowerShell or cmd (from Git Bash create_bd_design can fail).
# =============================================================================

set here [file normalize [file dirname [info script]]]
set xdc  [file normalize $here/xdc/cora_z7_07s_week07.xdc]

if {[info exists ::env(W7_BUILD_DIR)]} {
    set root [file normalize $::env(W7_BUILD_DIR)]
} elseif {[regexp {[^\x00-\x7F]} $here]} {
    set root C:/vivado_w7
    puts "NOTE: '$here' contains non-ASCII characters - building in $root"
} else {
    set root $here/build
}
file mkdir $root
puts "BUILD DIR: $root"

# ---- 1. project, PS, AXI GPIO (W7_S1 1.4 - 1.6)
create_project gpio_irq $root/vivado_prj/gpio_irq -part xc7z007sclg400-1 -force
set_property board_part digilentinc.com:cora-z7-07s:part0:1.1 [current_project]

create_bd_design design_1
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
    -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable"} \
    [get_bd_cells processing_system7_0]
set_property -dict [list \
    CONFIG.PCW_USE_M_AXI_GP0 {1} \
    CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
    CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1}    CONFIG.C_GPIO_WIDTH {4} \
    CONFIG.C_IS_DUAL {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} CONFIG.C_GPIO2_WIDTH {4} \
    CONFIG.C_INTERRUPT_PRESENT {1}] [get_bd_cells axi_gpio_0]

# ---- 2. bus, pins, interrupt wire (W7_S1 1.5 - 1.6)
apply_bd_automation -rule xilinx.com:bd_rule:axi4 \
    -config {Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/axi_gpio_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}} \
    [get_bd_intf_pins axi_gpio_0/S_AXI]
make_bd_pins_external -name sw4  [get_bd_pins axi_gpio_0/gpio_io_i]
make_bd_pins_external -name led4 [get_bd_pins axi_gpio_0/gpio2_io_o]
connect_bd_net [get_bd_pins axi_gpio_0/ip2intc_irpt] [get_bd_pins processing_system7_0/IRQ_F2P]
set_property name ila_sw4 [get_bd_nets -of_objects [get_bd_pins axi_gpio_0/gpio_io_i]]
set_property name ila_irq [get_bd_nets -of_objects [get_bd_pins axi_gpio_0/ip2intc_irpt]]

# ---- 3. System ILA: Debug on the axi_gpio_0/S_AXI bus, ila_sw4, ila_irq (W7_S1 1.7)
set axi_net [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_gpio_0/S_AXI]]
set sw_net  [get_bd_nets ila_sw4]
set irq_net [get_bd_nets ila_irq]
puts "DEBUG AXI NET: $axi_net"
set_property HDL_ATTRIBUTE.DEBUG true $axi_net
set_property HDL_ATTRIBUTE.DEBUG true $sw_net
set_property HDL_ATTRIBUTE.DEBUG true $irq_net
apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
    $axi_net {AXI_R_ADDRESS "Data and Trigger" AXI_R_DATA "Data and Trigger" AXI_W_ADDRESS "Data and Trigger" AXI_W_DATA "Data and Trigger" AXI_W_RESPONSE "Data and Trigger" CLK_SRC "/processing_system7_0/FCLK_CLK0" SYSTEM_ILA "Auto" APC_EN "0"} \
    $sw_net  {PROBE_TYPE "Data and Trigger" CLK_SRC "/processing_system7_0/FCLK_CLK0" SYSTEM_ILA "Auto"} \
    $irq_net {PROBE_TYPE "Data and Trigger" CLK_SRC "/processing_system7_0/FCLK_CLK0" SYSTEM_ILA "Auto"}]

validate_bd_design
save_bd_design
puts "BD CELLS: [lsort [get_bd_cells]]"
puts "BD PORTS: [lsort [get_bd_ports]]"
set ila [get_bd_cells -filter {VLNV =~ *system_ila*}]
puts "ILA: $ila  SLOTS=[get_property CONFIG.C_NUM_MONITOR_SLOTS $ila]  PROBES=[get_property CONFIG.C_NUM_OF_PROBES $ila]  DEPTH=[get_property CONFIG.C_DATA_DEPTH $ila]"
set seg [get_bd_addr_segs -of_objects [get_bd_addr_spaces processing_system7_0/Data]]
puts "AXI_GPIO ADDRESS: [get_property OFFSET $seg]  RANGE: [get_property RANGE $seg]"

# ---- 4. wrapper, xdc, bitstream, xsa (W7_S1 1.8)
add_files -norecurse [make_wrapper -files [get_files design_1.bd] -top]
add_files -fileset constrs_1 -norecurse $xdc
update_compile_order -fileset sources_1

launch_runs synth_1 -jobs 8
wait_on_run synth_1
open_run synth_1
set unplaced [get_ports -filter {PACKAGE_PIN == "" && DIRECTION != INOUT}]
puts "UNPLACED PORTS: [llength $unplaced] $unplaced"
close_design

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1
puts "IMPL: [get_property STATUS [get_runs impl_1]]"
puts "WNS: [get_property STATS.WNS [get_runs impl_1]]"
puts "LTX: [glob -nocomplain $root/vivado_prj/gpio_irq/gpio_irq.runs/impl_1/*.ltx]"

write_hw_platform -fixed -include_bit -force $root/vivado_prj/gpio_irq/design_1_wrapper.xsa
puts "XSA: $root/vivado_prj/gpio_irq/design_1_wrapper.xsa"
