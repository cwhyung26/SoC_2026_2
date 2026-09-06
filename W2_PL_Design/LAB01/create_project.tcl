# create_project.tcl
# Week 2 PL lab (Cora Z7-07S) - starter project.
#
# This script only creates the project and adds the RTL and the testbench.
# It does NOT add constraints (students make my.xdc from the GUI in W2_S2),
# and it does NOT build the Block Design, the Clocking Wizard, the System
# ILA or the bitstream - those are done by hand in W2_S1 / W2_S2. Use this
# to reach the same starting point quickly, or to reproduce the lab later.
#
# Usage:
#   cd <the LAB01 folder that holds this file>
#   vivado -mode gui -source create_project.tcl
#
# Output: ./project_w2_pl/ under this script's folder
# Board : Cora Z7-07S (board file must be installed - see W1_S2 section 2.2)

set script_dir [file normalize [file dirname [info script]]]
set proj_name  "project_w2_pl"
set proj_dir   [file join $script_dir $proj_name]

if {[file exists $proj_dir]} {
    puts "Removing existing $proj_dir and recreating it."
    file delete -force $proj_dir
}

create_project $proj_name $proj_dir -part xc7z007sclg400-1

if {[catch {set_property board_part digilentinc.com:cora-z7-07s:part0:1.1 [current_project]} err]} {
    puts "board_part 1.1 failed ($err) - looking for the newest installed version."
    set bp [lindex [get_board_parts -quiet *cora-z7-07s*] end]
    if {$bp ne ""} {
        set_property board_part $bp [current_project]
        puts "board_part set to $bp."
    } else {
        puts "Warning: cora-z7-07s board file not found. Proceeding with part only."
    }
}

# Design sources: reused hierarchical counter.
add_files -norecurse [list \
    [file join $script_dir rtl counter_n.v] \
    [file join $script_dir rtl pl_counter.v] ]
set_property top pl_counter [get_filesets sources_1]
update_compile_order -fileset sources_1

# Simulation source.
add_files -fileset sim_1 -norecurse [file join $script_dir tb tb_pl_counter.v]
set_property top tb_pl_counter [get_filesets sim_1]
update_compile_order -fileset sim_1

# No constraints added here. In W2_S2 the students assign reset_rtl -> D20 in
# I/O Planning and save it as my.xdc. See xdc/cora_z7_07s_week02.xdc for the
# reference result.

puts ""
puts "Done: $proj_dir/$proj_name.xpr"
puts "Next: W2_S1 - Block Design (Clocking Wizard + pl_counter) + System ILA,"
puts "              HDL wrapper, behavioural simulation on tb_pl_counter"
puts "      W2_S2 - synthesis, I/O Planning (reset_rtl -> D20), my.xdc,"
puts "              bitstream, hardware, System ILA (ALWAYS / BASIC capture)"
