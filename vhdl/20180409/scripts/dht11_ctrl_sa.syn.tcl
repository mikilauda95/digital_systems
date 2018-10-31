# IOs
array set ios {
	"clk"		{"L16" "LVCMOS33"}
	"sw[0]"		{"G15" "LVCMOS33"}
	"sw[1]"		{"P15" "LVCMOS33"}
	"sw[2]"		{"W13" "LVCMOS33"}
	"sw[3]"		{"T16" "LVCMOS33"}
	"led[0]"	{"M14" "LVCMOS33"}
	"led[1]"	{"M15" "LVCMOS33"}
	"led[2]"	{"G14" "LVCMOS33"}
	"led[3]"	{"D18" "LVCMOS33"}
	"btn0"   	{"R18" "LVCMOS33"}
	"btn1"   	{"P16" "LVCMOS33"}
	"data"		{"V12" "LVCMOS33"}
}

proc usage {} {
	puts "\
usage: vivado -mode batch -source <script> -tclargs <vhdldir> <init> <tmax> <cmax>
  <vhdldir>:  absolute path of VHDL source files directory
  <init>:     duration of low pulse of _init_ command in micro-seconds
  <tmax>:     maximum value of timer
  <cmax>:     maximum value of counter"
}

if { $argc == 4 } {
	set vhdldir [lindex $argv 0]
	set init    [lindex $argv 1]
	set tmax    [lindex $argv 2]
	set cmax    [lindex $argv 3]
} else {
	usage
	exit -1
}

set ip dht11_ctrl_sa
set lib DHT11
set vendor www.telecom-paristech.fr
set board [get_board_parts digilentinc.com:zybo*]
set freq 125
set period [expr 1000.0 / $freq]

#############
# Create IP #
#############
create_project -part xc7z010clg400-1 -force $ip $ip
add_files $vhdldir/timer2.vhd $vhdldir/counter.vhd $vhdldir/sr2.vhd $vhdldir/sm2.vhd $vhdldir/edge.vhd $vhdldir/dht11_ctrl.vhd $vhdldir/dht11_ctrl_sa.vhd
import_files -force -norecurse
ipx::package_project -root_dir $ip -vendor $vendor -library $lib -force $ip
close_project

############################
## Create top level design #
############################
set top top
set project [create_project -part xc7z010clg400-1 -force $top .]
set fileset [current_fileset]
set_property board_part $board $project
set_property ip_repo_paths ./$ip $fileset
update_ip_catalog
create_bd_design "$top"
set ip [create_bd_cell -type ip -vlnv [get_ipdefs *$vendor:$lib:$ip:*] $ip]
set_property CONFIG.freq $freq $ip
set_property CONFIG.init $init $ip
set_property CONFIG.tmax $tmax $ip
set_property CONFIG.cmax $cmax $ip
set ps7 [create_bd_cell -type ip -vlnv [get_ipdefs *xilinx.com:ip:processing_system7:*] ps7]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } $ps7
set_property CONFIG.PCW_USE_M_AXI_GP0 0 $ps7

# Interconnections
# Primary IOs
create_bd_port -dir I clk
connect_bd_net [get_bd_pins /$ip/clk] [get_bd_ports clk]
create_bd_port -dir I btn0
connect_bd_net [get_bd_pins /$ip/areset] [get_bd_ports btn0]
create_bd_port -dir I btn1
connect_bd_net [get_bd_pins /$ip/btn] [get_bd_ports btn1]
create_bd_port -dir I -from 3 -to 0 sw
connect_bd_net [get_bd_pins /$ip/sw] [get_bd_ports sw]
create_bd_port -dir O -from 3 -to 0 led
connect_bd_net [get_bd_pins /$ip/led] [get_bd_ports led]
create_bd_port -dir IO data
connect_bd_net [get_bd_pins /$ip/data] [get_bd_ports data]

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

foreach io [ array names ios ] {
	set pin [ lindex $ios($io) 0 ]
	set std [ lindex $ios($io) 1 ]
	set_property package_pin $pin [get_ports $io]
	set_property iostandard $std [get_ports [list $io]]
}
# set_property pulltype pullup [get_ports data]

# Timing constraints
create_clock -period $period [get_ports clk]
set clock [get_clocks]
set_false_path -from $clock -to [get_ports {led[*] data}]
set_false_path -from [get_ports {btn0 btn1 sw[*] data}] -to $clock

# Implementation
save_constraints
set run [get_runs impl*]
reset_run $run
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true $run
launch_runs -to_step write_bitstream $run
wait_on_run $run

# Messages
set rundir [pwd]/$top.runs/$run
puts ""
puts "\[VIVADO\]: done"
puts "  bitstream in $rundir/${top}_wrapper.bit"
puts "  resource utilization report in $rundir/${top}_wrapper_utilization_placed.rpt"
puts "  timing report in $rundir/${top}_wrapper_timing_summary_routed.rpt"
