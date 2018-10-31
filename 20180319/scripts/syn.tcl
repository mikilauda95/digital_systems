# Source myself to get rid of annoying echo of TCL commands
if ![ info exists already_sourced ] {
	set already_sourced 1
	source [file normalize [info script]]
}

#############################################################################
# Synthesis parameters can be passed on the command line when invoking
# the synthesizer:
#   $ PARAM1=VAL1 PARAM2=VAL2 dc_shell -x "source /path/to/script.tcl"
# or by exporting environment variables before the invocation:
#   $ export PARAM1=VAL1
#   $ export PARAM2=VAL2
#   $ dc_shell -x "source /path/to/script.tcl"
#
# They can also be defined by modifying the TCL script (see section
# "Synthesis parameters" below):
#   set PARAM1 VAL1
#
# Parameters defined on the command line override parameters defined in
# the script.
#############################################################################

#############################################################################
# Synthesis parameters
#############################################################################

# Path to VHDL source file
#set VHD /homes/simili/dig_sys/ds-2018/20180319/vhdl/g1_doublecom.vhd

# Name of top level entity
set TOP g1

# Name of clock port, needed for proper handling of synchronous designs
set CLK clk

# Target clock period (ns)
for {set i 1} {$i < 2} {incr i} {
    #set CP [expr {0.7 + $i * 0.1}]
    set CP 2.0

# External delay on non-clock input signals (ns)
set IDEL 0.5

# External delay on output signals (ns)
set ODEL 0.5

# Cell driving all inputs but clock
set DRV DFFX2_RVT

# External load on outputs (fF)
set LOAD 2

#############################################################################
# You shouldn't change anything after this line. But of course if you
# know what you're doing...
#############################################################################

# Automatic selection of the wire load model (boolean)
set AWLS true

# Generate HTML log file (boolean)
set HLE true

# Name of HTML log file, e.g. dc_log.html
set HLFN dc_log.html

# Maximum number of cores to use (1 to 16)
set MCORES 4

# Name of target standard cells library
set LIB saed32rvt_tt0p85v25c.db

#############################################################################
# Synthesis parameters priority (command-line > script)
#
# If an environment variable FOO exists, its value is used for parameter FOO.
# Else the value defined in the script is used.
#
# Example of use: to define the source file and top level entity using
# environment variables:
#   $ export VHD=/home/mary/foo.vhd
#   $ export TOP=foo
#   $ dc_shell -x "source syn.tcl"
#############################################################################

set PARAMS { VHD TOP CLK CP IDEL ODEL DRV LOAD AWLS HLE HLFN MCORES }
foreach P $PARAMS {
        if [ info exists ::env($P) ] {
                eval "set $P $::env($P)"
        }
}

#############################################################################
# Synthesis parameters, apply
#############################################################################

# Target standard cells library
if { ![info exists LIB] } {
        puts "** ERROR: Target standard cells library undefined"
        exit 1
}
puts "** INFO: Target standard cells library: $LIB"
set_app_var target_library $LIB

# Maximum number of CPU cores to use
if { [info exists MCORES] } {
        puts "** INFO: Maximum number of cores to use: $MCORES"
        set_host_options -max_cores $MCORES
}

# Generate HTML log file
if { [info exists HLE] } {
        puts "** INFO: Generate HTML log file: $HLE"
        set_app_var html_log_enable $HLE
}

# Name of HTML log file
if { [info exists HLFN] } {
        puts "** INFO: Name of HTML log file: $HLFN"
        set_app_var html_log_filename $HLFN
}

# In case you know what you are doing and you know what the following variables
# do, adapt their values to your needs. Else, leave them as they are, the
# default values are reasonable ones.

# Search path for libraries, library definitions
set edk ${synopsys_root}/../../../EDK/SAED32_EDK/lib
set search_path [concat $search_path ${edk}/stdcell_rvt/db_ccs]
set search_path [concat $search_path ${edk}/stdcell_rvt/db_nldm]
set search_path [concat $search_path ${edk}/stdcell_hvt/db_ccs]
set search_path [concat $search_path ${edk}/stdcell_hvt/db_nldm]
set link_library  [list * $target_library]
set symbol_library ""

#############################################################################
# Run the synthesis design flow
#############################################################################

# Read VHDL source file and elaborate
if { ![info exists VHD] } {
        puts "** ERROR: VHDL source file (VHD) undefined"
        exit 1
}
if { ![file exists $VHD] } {
        puts "** ERROR: $VHD: file not found"
        exit 1
}
puts "** INFO: Analysing: $VHD"
analyze -format vhdl -library work $VHD

if { ![info exists TOP] } {
        puts "** ERROR: Top-level entity (TOP) undefined"
        exit 1
}
puts "** INFO: Top-level entity: $TOP"
elaborate $TOP
if { [current_design] == "" } {
        puts "** ERROR: Could not elaborate $TOP top-level entity"
        exit 1
}

# Set timing constraints
if { ![info exists CLK] } {
        set CLK virtual_clock
        puts "** INFO: Clock name undefined, using the default ($CLK)"
}

if { ![info exists CP] } {
        puts "** ERROR: Target clock period undefined"
        exit 1
}
puts "** INFO: Clock period: $CP"

if {[sizeof_collection [get_ports $CLK]] > 0} {
        create_clock -period $CP $CLK
} else {
        create_clock -period $CP -name $CLK
}

if { [info exists IDEL] } {
        puts "** INFO: Input delays: $IDEL"
        set_input_delay -clock $CLK $IDEL [all_inputs]
}

if { [info exists ODEL] } {
        puts "** INFO: Output delays: $ODEL"
        set_output_delay -clock $CLK $ODEL [all_outputs]
}

# Set other design constraints
if { [info exists DRV] } {
        puts "** INFO: Driving cell: $DRV"
        set_driving_cell -no_design_rule -lib_cell $DRV [all_inputs]
}

# If real clock, set infinite drive strength
if {[sizeof_collection [get_ports $CLK]] > 0} {
        set_drive 0 $CLK
}

if { [info exists LOAD] } {
        puts "** INFO: Output load: $LOAD"
        set_load $LOAD [all_outputs]
}

# Turn on auto wire load selection (library must support this feature)
if [ info exists AWLS ] {
        puts "** INFO: Automatic wire load selection: $AWLS"
        set auto_wire_load_selection $AWLS
}

# Check design
check_design

# Synthesize
#compile
#compile -area_effort high -power_effort none
compile_ultra

set title $TOP
append $title "_"
append $title $i


# Reports
echo "*********************"
echo "***** AREA REPORT ***"
echo "*********************"
report_area
report_area > $title.area
echo "***********************"
echo "***** TIMING REPORT ***"
echo "***********************"
report_timing
report_timing > $title.timing

# Write output files
write_file -format verilog -hierarchy -output $title.v $TOP
write_file -format ddc -hierarchy -output $title.ddc $TOP

# Launch GUI
# gui_start
# gui_create_schematic

# Quit
#quit

# Target technology libraries: in 32/28 nm node, the libraries are named according
# the following syntax:
#
#   saed32Xvt_YYVpVVvTTTc.db
#
# where:
#
# - Xvt = hvt, rvt or lvt, for high, regular and low voltage threshold. The
#   higher the voltage threshold, the slower the library and the lower the
#   static power.
# - YY = ff, tt or ss, for fast-fast, typical-typical and slow-slow, 3 different
#   characterization corners for 3 different manufacturing qualities of N-P
#   transistors. A fast-fast chip is faster than a slow-slow but if the
#   synthesizer is asked to work in the fast-fast corner, it can be that, after
#   manufacturing, typical-typical and slow-slow chips are not fast enough and
#   must be discarded...
# - VpVVv = the power supply voltage used for characterization (in volts).
# - TTT = the temperature used for characterization (in Celsius degrees). If the
#   first character in TTT is a 'n', the temperature is negative.
#
# Example: the saed32hvt_ss0p75v125c.db library is a high voltage threshold one
# (slower than regular or low voltage threshold) with low leakage power. It has
# been characterized for a slow-slow manufacturing process, with a 0.75 V
# voltage and at a 125 C temperature. Use it if you are more concerned with
# leakage power than speed and you want all your manufactured circuits, even the
# ones manufactured in the slow-slow corner, to operate normally with a rather
# low 0.75 V power supply and at a rather high 125 C temperature.
#
# The following libraries are available:
#
# saed32hvt_ff0p85v125c.db
# saed32hvt_ff0p85v25c.db
# saed32hvt_ff0p85vn40c.db
# saed32hvt_ff0p95v125c.db
# saed32hvt_ff0p95v25c.db
# saed32hvt_ff0p95vn40c.db
# saed32hvt_ff1p16v125c.db
# saed32hvt_ff1p16v25c.db
# saed32hvt_ff1p16vn40c.db
# saed32hvt_ss0p75v125c.db
# saed32hvt_ss0p75v25c.db
# saed32hvt_ss0p75vn40c.db
# saed32hvt_ss0p7v125c.db
# saed32hvt_ss0p7v25c.db
# saed32hvt_ss0p7vn40c.db
# saed32hvt_ss0p95v125c.db
# saed32hvt_ss0p95v25c.db
# saed32hvt_ss0p95vn40c.db
# saed32hvt_tt0p78v125c.db
# saed32hvt_tt0p78v25c.db
# saed32hvt_tt0p78vn40c.db
# saed32hvt_tt0p85v125c.db
# saed32hvt_tt0p85v25c.db
# saed32hvt_tt0p85vn40c.db
# saed32hvt_tt1p05v125c.db
# saed32hvt_tt1p05v25c.db
# saed32hvt_tt1p05vn40c.db
# saed32lvt_ff0p85v125c.db
# saed32lvt_ff0p85v125c.lib
# saed32lvt_ff0p85v25c.db
# saed32lvt_ff0p85v25c.lib
# saed32lvt_ff0p85vn40c.db
# saed32lvt_ff0p85vn40c.lib
# saed32lvt_ff0p95v125c.db
# saed32lvt_ff0p95v125c.lib
# saed32lvt_ff0p95v25c.db
# saed32lvt_ff0p95v25c.lib
# saed32lvt_ff0p95vn40c.db
# saed32lvt_ff0p95vn40c.lib
# saed32lvt_ff1p16v125c.db
# saed32lvt_ff1p16v125c.lib
# saed32lvt_ff1p16v25c.db
# saed32lvt_ff1p16v25c.lib
# saed32lvt_ff1p16vn40c.db
# saed32lvt_ff1p16vn40c.lib
# saed32lvt_ss0p75v125c.db
# saed32lvt_ss0p75v125c.lib
# saed32lvt_ss0p75v25c.db
# saed32lvt_ss0p75v25c.lib
# saed32lvt_ss0p75vn40c.db
# saed32lvt_ss0p75vn40c.lib
# saed32lvt_ss0p7v125c.db
# saed32lvt_ss0p7v125c.lib
# saed32lvt_ss0p7v25c.db
# saed32lvt_ss0p7v25c.lib
# saed32lvt_ss0p7vn40c.db
# saed32lvt_ss0p7vn40c.lib
# saed32lvt_ss0p95v125c.db
# saed32lvt_ss0p95v125c.lib
# saed32lvt_ss0p95v25c.db
# saed32lvt_ss0p95v25c.lib
# saed32lvt_ss0p95vn40c.db
# saed32lvt_ss0p95vn40c.lib
# saed32lvt_tt0p78v125c.db
# saed32lvt_tt0p78v125c.lib
# saed32lvt_tt0p78v25c.db
# saed32lvt_tt0p78v25c.lib
# saed32lvt_tt0p78vn40c.db
# saed32lvt_tt0p78vn40c.lib
# saed32lvt_tt0p85v125c.db
# saed32lvt_tt0p85v125c.lib
# saed32lvt_tt0p85v25c.db
# saed32lvt_tt0p85v25c.lib
# saed32lvt_tt0p85vn40c.db
# saed32lvt_tt0p85vn40c.lib
# saed32lvt_tt1p05v125c.db
# saed32lvt_tt1p05v125c.lib
# saed32lvt_tt1p05v25c.db
# saed32lvt_tt1p05v25c.lib
# saed32lvt_tt1p05vn40c.db
# saed32lvt_tt1p05vn40c.lib
# saed32rvt_ff0p85v125c.db
# saed32rvt_ff0p85v25c.db
# saed32rvt_ff0p85vn40c.db
# saed32rvt_ff0p95v125c.db
# saed32rvt_ff0p95v25c.db
# saed32rvt_ff0p95vn40c.db
# saed32rvt_ff1p16v125c.db
# saed32rvt_ff1p16v25c.db
# saed32rvt_ff1p16vn40c.db
# saed32rvt_ss0p75v125c.db
# saed32rvt_ss0p75v25c.db
# saed32rvt_ss0p75vn40c.db
# saed32rvt_ss0p7v125c.db
# saed32rvt_ss0p7v25c.db
# saed32rvt_ss0p7vn40c.db
# saed32rvt_ss0p95v125c.db
# saed32rvt_ss0p95v25c.db
# saed32rvt_ss0p95vn40c.db
# saed32rvt_tt0p78v125c.db
# saed32rvt_tt0p78v25c.db
# saed32rvt_tt0p78vn40c.db
# saed32rvt_tt0p85v125c.db
# saed32rvt_tt0p85v25c.db
# saed32rvt_tt0p85vn40c.db
# saed32rvt_tt1p05v125c.db
# saed32rvt_tt1p05v25c.db
# saed32rvt_tt1p05vn40c.db
#
# Example:
#
# saed32rvt_tt0p85v25c.db is a regular threshold voltage library, that is, it is
# designed for medium leakage power and medium speed. It has been characterized
# with a 0.85 volts power supply, at 25 C° and for a Typical-Typical
# manufacturing quality. Use this library if your design is more sensitive to
# leakage power than to speed, if you accept to drop the Slow-Slow samples after
# manufacturing and if you want your chips to operate in medium voltage and
# temperature conditions. Be warned, however: if your speed contraints are too
# tight, the synthesizer will have a much more difficult job to do; it may fail
# or end up with a larger silicon area than expected.
}
