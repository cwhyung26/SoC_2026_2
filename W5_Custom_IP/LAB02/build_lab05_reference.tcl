# =============================================================================
# build_lab05_reference.tcl - W5 reference build (custom IP my_io + System ILA)
#
#   vivado -mode batch -source build_lab05_reference.tcl
#
# Builds, from nothing, the same result as chapters 1 and 2 done by hand:
#   1. custom AXI4-Lite IP my_io (Create and Package New IP, 4 registers),
#      the generated HDL replaced by hdl/*.v, then Re-Package IP
#   2. project lab05: ZYNQ7 PS + my_io_0, Connection Automation (S00_AXI),
#      the four pins made external and renamed (led4, led3, sw4, btn2)
#   3. Debug on the S00_AXI bus and the four pin nets -> System ILA
#   4. xdc, bitstream (+ .ltx), design_1_wrapper.xsa (bitstream included)
#
# Vivado fails on non-ASCII or long paths. If this script sits under such a
# path (the course repo is under ...\문서\GitHub\...), it builds in
# C:/vivado_w5 instead. Set W5_BUILD_DIR to use another location.
# =============================================================================

set here [file normalize [file dirname [info script]]]
set hdl  [file normalize $here/../LAB01/hdl]
set xdc  [file normalize $here/../LAB02/xdc/cora_z7_07s_week05.xdc]

if {[info exists ::env(W5_BUILD_DIR)]} {
    set root [file normalize $::env(W5_BUILD_DIR)]
} elseif {[regexp {[^\x00-\x7F]} $here]} {
    set root C:/vivado_w5
    puts "NOTE: '$here' contains non-ASCII characters - building in $root"
} else {
    set root $here/build
}
file mkdir $root
puts "BUILD DIR: $root"

# ---- 1. IP: template -> edited HDL -> Re-Package (done in throw-away projects)
create_project -in_memory -part xc7z007sclg400-1
file delete -force $root/ip_repo $root/ip_edit
create_peripheral user.org user my_io 1.0 -dir $root/ip_repo
set core [ipx::find_open_core user.org:user:my_io:1.0]
add_peripheral_interface S00_AXI -interface_mode slave -axi_type lite $core
generate_peripheral -driver $core
write_peripheral $core

foreach f {my_io_v1_0.v my_io_v1_0_S00_AXI.v} {
    file copy -force $hdl/$f $root/ip_repo/my_io_1_0/hdl/$f
}
ipx::edit_ip_in_project -upgrade true -name edit_my_io_v1_0 \
    -directory $root/ip_edit $root/ip_repo/my_io_1_0/component.xml
update_compile_order -fileset sources_1
ipx::merge_project_changes files          [ipx::current_core]
ipx::merge_project_changes hdl_parameters [ipx::current_core]
ipx::merge_project_changes ports          [ipx::current_core]
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums  [ipx::current_core]
ipx::check_integrity   [ipx::current_core]
ipx::save_core         [ipx::current_core]
close_project -delete
close_project

# ---- 2. project and block design
create_project lab05 $root/vivado_prj/lab05 -part xc7z007sclg400-1 -force
set_property board_part digilentinc.com:cora-z7-07s:part0:1.1 [current_project]
set_property ip_repo_paths $root/ip_repo [current_project]
update_ip_catalog

create_bd_design design_1
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
    -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable"} \
    [get_bd_cells processing_system7_0]
create_bd_cell -type ip -vlnv user.org:user:my_io:1.0 my_io_0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 \
    -config {Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/my_io_0/S00_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}} \
    [get_bd_intf_pins my_io_0/S00_AXI]
foreach p {led4 led3 sw4 btn2} {
    make_bd_pins_external [get_bd_pins my_io_0/$p]
    set_property name $p [get_bd_ports ${p}_0]
}

# ---- 3. System ILA: Debug on the S00_AXI bus and the four pin nets
set axi_net  [get_bd_intf_nets -of_objects [get_bd_intf_pins my_io_0/S00_AXI]]
set pin_nets [get_bd_nets -of_objects [get_bd_pins {my_io_0/led4 my_io_0/led3 my_io_0/sw4 my_io_0/btn2}]]
puts "DEBUG AXI NET: $axi_net"
puts "DEBUG PIN NETS: $pin_nets"
set_property HDL_ATTRIBUTE.DEBUG true $axi_net
set_property HDL_ATTRIBUTE.DEBUG true $pin_nets
set dbg [list $axi_net {AXI_R_ADDRESS "Data and Trigger" AXI_R_DATA "Data and Trigger" AXI_W_ADDRESS "Data and Trigger" AXI_W_DATA "Data and Trigger" AXI_W_RESPONSE "Data and Trigger" CLK_SRC "/processing_system7_0/FCLK_CLK0" SYSTEM_ILA "Auto" APC_EN "0"}]
foreach n $pin_nets {
    lappend dbg $n {PROBE_TYPE "Data and Trigger" CLK_SRC "/processing_system7_0/FCLK_CLK0" SYSTEM_ILA "Auto"}
}
apply_bd_automation -rule xilinx.com:bd_rule:debug -dict $dbg

validate_bd_design
save_bd_design
puts "BD CELLS: [lsort [get_bd_cells]]"
set ila [get_bd_cells -filter {VLNV =~ *system_ila*}]
puts "ILA: $ila  SLOTS=[get_property CONFIG.C_NUM_MONITOR_SLOTS $ila]  PROBES=[get_property CONFIG.C_NUM_OF_PROBES $ila]  DEPTH=[get_property CONFIG.C_DATA_DEPTH $ila]"
set seg [get_bd_addr_segs -of_objects [get_bd_addr_spaces processing_system7_0/Data]]
puts "MY_IO ADDRESS: [get_property OFFSET $seg]  RANGE: [get_property RANGE $seg]"

# ---- 4. wrapper, xdc, bitstream, xsa
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
puts "LTX: [glob -nocomplain $root/vivado_prj/lab05/lab05.runs/impl_1/*.ltx]"

write_hw_platform -fixed -include_bit -force $root/vivado_prj/lab05/design_1_wrapper.xsa
puts "XSA: $root/vivado_prj/lab05/design_1_wrapper.xsa"
