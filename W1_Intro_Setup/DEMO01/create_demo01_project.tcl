# create_demo01_project.tcl
# Builds the W1_S2 demo project automatically.
# In class the instructor walks through the New Project wizard by hand; this
# script lets a student who fell behind reproduce the exact same project later.
#
# Usage (Vivado Tcl Console or a shell):
#   cd <the DEMO01 folder that holds this file>
#   vivado -mode batch -source create_demo01_project.tcl        # batch: create only
#   # or, in the Vivado GUI Tcl Console:
#   source C:/.../W1_Intro_Setup/DEMO01/create_demo01_project.tcl
#
# Output location: ./project_demo01/ under this script's folder
# Board          : Cora Z7-07S (the board file must be installed - see 2.2)

set script_dir [file normalize [file dirname [info script]]]
set proj_name  "project_demo01"
set proj_dir   [file join $script_dir $proj_name]

# If a project with the same name already exists, delete it (always rebuild fresh).
if {[file exists $proj_dir]} {
    puts "Removing existing $proj_dir and recreating it."
    file delete -force $proj_dir
}

# Create a pure RTL project (no Block Design - covered in week 2).
create_project $proj_name $proj_dir -part xc7z007sclg400-1

# Set the Cora Z7-07S board. The trailing version can differ by installed board
# file, so on failure retry with the newest installed version.
if {[catch {set_property board_part digilentinc.com:cora-z7-07s:part0:1.1 [current_project]} err]} {
    puts "board_part 1.1 failed ($err) - looking for the newest installed version."
    set bp [lindex [get_board_parts *cora-z7-07s*] end]
    if {$bp ne ""} {
        set_property board_part $bp [current_project]
        puts "board_part set to $bp."
    } else {
        puts "Warning: cora-z7-07s board file not found. Proceeding with part only (xc7z007sclg400-1)."
    }
}

# Add the design source (for the synthesis/implementation/bitstream demo).
add_files -norecurse [file join $script_dir rtl led_counter_demo.v]

# Add the simulation source (for the Behavioral Simulation demo).
add_files -fileset sim_1 -norecurse [file join $script_dir sim tb_led_counter_demo.v]

# Add the Cora Z7-07S pin constraints (needed for Generate Bitstream).
add_files -fileset constrs_1 -norecurse [file join $script_dir constraints led_counter_demo.xdc]

# Fix up the top modules.
set_property top led_counter_demo [get_filesets sources_1]
set_property top tb_led_counter_demo [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts ""
puts "Done: $proj_dir/$proj_name.xpr"
puts "Next: in Flow Navigator run Run Synthesis -> Run Implementation -> Generate Bitstream"
