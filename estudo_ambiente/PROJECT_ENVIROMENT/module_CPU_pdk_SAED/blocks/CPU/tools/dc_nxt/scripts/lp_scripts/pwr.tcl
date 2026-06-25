set_app_var sh_new_variable_message false
set_app_var power_enable_timing_analysis true
set_app_var power_enable_multi_rtl_to_gate_mapping true
set_app_var power_enable_advanced_sv_name_mapping true

source ./rm_setup/common_setup.tcl

set_app_var search_path    "$search_path $ADDITIONAL_SEARCH_PATH"
set_app_var target_library  $TARGET_LIBRARY_FILES
set_app_var link_library   "* $target_library"

set_app_var power_analysis_mode averaged
#set_app_var power_analysis_mode time_based

read_verilog ./results/netlist_dc.v
current_design my_design
link
read_sdc ./results/constraints_dc.sdc
read_parasitics ./results/parasitics_dc.spef

source -echo ./results/primepower_dc.saif.map
if {[get_app_var power_analysis_mode] == "averaged"} {
    puts "Reading SAIF file"
    read_saif ./sim/top_rtl.fsdb.saif -strip_path top_tb/top
} else {
    puts "Reading FSDB file"
    read_fsdb ./sim/top_rtl.fsdb -strip_path top_tb/top -rtl -format verilog
}
report_switching_activity
set_app_var power_enable_clock_scaling true
set_power_clock_scaling -ratio 3.335 [get_clocks]
update_power
report_power

return
exit
