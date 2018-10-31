# Source myself to get rid of annoying echo of TCL commands
if ![ info exists already_sourced ] {
	set already_sourced 1
	source [file normalize [info script]]
}

# Search path for libraries, library definitions
set LIB saed32rvt_tt0p85v25c.db
set_app_var target_library $LIB
set edk ${synopsys_root}/../../../EDK/SAED32_EDK/lib
set search_path [concat $search_path ${edk}/stdcell_rvt/db_ccs]
set search_path [concat $search_path ${edk}/stdcell_rvt/db_nldm]
set search_path [concat $search_path ${edk}/stdcell_hvt/db_ccs]
set search_path [concat $search_path ${edk}/stdcell_hvt/db_nldm]
set link_library  [list * $target_library]
set symbol_library ""
puts "** INFO: Target standard cells library: $LIB"

# Read design, launch GUI, show schematic
read_ddc g1.ddc
gui_start
gui_create_schematic
