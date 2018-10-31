#
# Copyright (C) Telecom ParisTech
# 
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
#

set part "xc7z010clg400-1"
set board [get_board_parts digilentinc.com:zybo*]
array set ios {
	"switch0"       {"G15" "LVCMOS33"}
	"wire_in"       {"V12" "LVCMOS33"}
	"wire_out"      {"W16" "LVCMOS33"}
	"led[0]"        {"M14" "LVCMOS33"}
	"led[1]"        {"M15" "LVCMOS33"}
	"led[2]"        {"G14" "LVCMOS33"}
	"led[3]"        {"D18" "LVCMOS33"}
}
puts "*********************************************"
puts "Summary of build parameters"
puts "*********************************************"
puts "Board: $board"
puts "Part: $part"
puts "*********************************************"

#####################
# Create CT project #
#####################
create_project -part $part -force ct ct
add_files ct.vhd
import_files -force -norecurse
ipx::package_project -root_dir ct -vendor www.telecom-paristech.fr -library CT -force ct
close_project

############################
## Create top level design #
############################
set top top
create_project -part $part -force $top .
set_property board_part $board [current_project]
set_property ip_repo_paths { ./ct } [current_fileset]
update_ip_catalog
create_bd_design "$top"
set ps7 [create_bd_cell -type ip -vlnv [get_ipdefs *xilinx.com:ip:processing_system7:*] ps7]
set ct [create_bd_cell -type ip -vlnv [get_ipdefs *www.telecom-paristech.fr:CT:ct:*] ct]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } $ps7
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {0}] $ps7

# Interconnections
# Primary IOs
create_bd_port -dir O -from 3 -to 0 led
connect_bd_net [get_bd_pins /ct/led] [get_bd_ports led]
create_bd_port -dir I switch0
connect_bd_net [get_bd_pins /ct/switch0] [get_bd_ports switch0]
create_bd_port -dir I wire_in
connect_bd_net [get_bd_pins /ct/wire_in] [get_bd_ports wire_in]
create_bd_port -dir O wire_out
connect_bd_net [get_bd_pins /ct/wire_out] [get_bd_ports wire_out]

# Synthesis flow
validate_bd_design
set files [get_files *$top.bd]
generate_target all $files
add_files -norecurse -force [make_wrapper -files $files -top]
save_bd_design
set run [get_runs synth*]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none $run
launch_runs $run
wait_on_run $run
open_run $run

# IOs
foreach io [ array names ios ] {
	set pin [ lindex $ios($io) 0 ]
	set std [ lindex $ios($io) 1 ]
	set_property package_pin $pin [get_ports $io]
	set_property iostandard $std [get_ports [list $io]]
}

# Implementation
save_constraints
set run [get_runs impl*]
reset_run $run
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true $run
launch_runs -to_step write_bitstream $run
wait_on_run $run

# Messages
set rundir $top.runs/$run
puts ""
puts "\[VIVADO\]: done"
puts "  bitstream in $rundir/${top}_wrapper.bit"
puts "  resource utilization report in $rundir/${top}_wrapper_utilization_placed.rpt"
puts "  timing report in $rundir/${top}_wrapper_timing_summary_routed.rpt"
