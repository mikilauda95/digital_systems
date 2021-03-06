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
set frequency 125
set timeout 50000
array set ios {
	"clk"		{ "L16" "LVCMOS33" }
    "areset" 	{ "R18" "LVCMOS33"}
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
puts "Frequency: $frequency MHz"
puts "Timeout: $timeout µs"
puts "*********************************************"

proc usage {} {
	puts "\
usage: vivado -mode batch -source <script> -notrace -tclargs <vhddir>
  <vhddir>:  absolute path of VHDL source directory"
}

if { $argc == 1 } {
	set vhddir [lindex $argv 0]
} else {
	usage
	exit -1
}

set ip lb
set lib LB
set vendor www.telecom-paristech.fr

#####################
# Create LB project #
#####################
create_project -part $part -force $ip $ip
add_files $vhddir/sr.vhd $vhddir/timer.vhd $vhddir/$ip.vhd
import_files -force -norecurse
ipx::package_project -root_dir $ip -vendor $vendor -library $lib -force $ip
close_project

############################
## Create top level design #
############################
set top top
create_project -part $part -force $top .
set_property board_part $board [current_project]
set_property ip_repo_paths [ list ./$ip ] [current_fileset]
update_ip_catalog
create_bd_design "$top"
set ps7 [create_bd_cell -type ip -vlnv [get_ipdefs *xilinx.com:ip:processing_system7:*] ps7]
set lb [create_bd_cell -type ip -vlnv [get_ipdefs *$vendor:$lib:$ip:*] $ip]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } $ps7
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {0}] $ps7
set_property -dict [list CONFIG.freq $frequency CONFIG.timeout $timeout] $lb

# Interconnections
# Primary IOs
create_bd_port -dir I -type clk clk
connect_bd_net [get_bd_pins /$ip/clk] [get_bd_ports clk]
create_bd_port -dir I areset
connect_bd_net [get_bd_pins /$ip/areset] [get_bd_ports areset]
create_bd_port -dir O -type data -from 3 -to 0 led
connect_bd_net [get_bd_pins /$ip/led] [get_bd_ports led]

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

# Clocks and timing
create_clock -name clk -period [expr 1000.0 / $frequency] [get_ports clk]
set_false_path -from clk -to [get_ports led[*]]
set_false_path -from [get_ports areset] -to clk

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
