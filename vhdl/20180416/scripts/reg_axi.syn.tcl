# IOs
array set ios {
	"sw[0]"		{ "G15" "LVCMOS33" }
	"sw[1]"		{ "P15" "LVCMOS33" }
	"sw[2]"		{ "W13" "LVCMOS33" }
	"sw[3]"		{ "T16" "LVCMOS33" }
	"led[0]"	{ "M14" "LVCMOS33" }
	"led[1]"	{ "M15" "LVCMOS33" }
	"led[2]"	{ "G14" "LVCMOS33" }
	"led[3]"	{ "D18" "LVCMOS33" }
}

proc usage {} {
	puts "\
usage: vivado -mode batch -source <script> -tclargs <ds-2018>
  <ds-2018>: absolute path of ds-2018 repository clone"
}

if { $argc == 1 } {
	set ds2018 [lindex $argv 0]
} else {
	usage
	exit -1
}

set ip reg_axi
set lib DS2018
set vendor www.telecom-paristech.fr
set part "xc7z010clg400-1"
set board [get_board_parts digilentinc.com:zybo*]
set freq 100
set period [expr 1000.0 / $freq]

#############
# Create IP #
#############
create_project -part xc7z010clg400-1 -force $ip $ip
add_files $ds2018/vhdl/axi_pkg.vhd $ds2018/20180416/vhdl/reg_axi.vhd
import_files -force -norecurse
ipx::package_project -root_dir $ip -vendor $vendor -library $lib -force $ip
close_project

############################
## Create top level design #
############################
set top top
set project [create_project -part $part -force $top .]
set fileset [current_fileset]
set_property board_part $board $project
set_property ip_repo_paths ./$ip $fileset
update_ip_catalog
create_bd_design "$top"
set ip [create_bd_cell -type ip -vlnv [get_ipdefs *$vendor:$lib:$ip:*] $ip]
set ps7 [create_bd_cell -type ip -vlnv [get_ipdefs *xilinx.com:ip:processing_system7:*] ps7]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } $ps7
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $freq] $ps7
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1}] $ps7
set_property -dict [list CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {1}] $ps7

# Interconnections
# Primary IOs
create_bd_port -dir I -from 3 -to 0 sw
connect_bd_net [get_bd_pins /$ip/sw] [get_bd_ports sw]
create_bd_port -dir O -from 3 -to 0 led
connect_bd_net [get_bd_pins /$ip/led] [get_bd_ports led]
# ps7 - reg_axi
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins /$ip/s0_axi]

# Addresses ranges
set_property offset 0x40000000 [get_bd_addr_segs -of_object [get_bd_intf_pins /ps7/M_AXI_GP0]]
set_property range 4K [get_bd_addr_segs -of_object [get_bd_intf_pins /ps7/M_AXI_GP0]]

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

# Timing constraints
set clock [get_clocks]
set_false_path -from $clock -to [get_ports {led[*]}]
set_false_path -from [get_ports {sw[*]}] -to $clock

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
