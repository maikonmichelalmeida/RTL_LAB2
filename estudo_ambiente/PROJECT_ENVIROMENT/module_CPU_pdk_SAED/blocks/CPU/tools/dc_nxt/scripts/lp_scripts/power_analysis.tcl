
#Task 2.1
set SAIF_FILE "../outputs/top_rtl.activity.saif"
set INSTANCE_NAME "top_tb/uut"

if {$SAIF_FILE == ""} {
  puts "Running infer_switching_activity"
  infer_switching_activity -sci_based all -apply
} else {
  # Reading the SAIF file
  # -instance_name  (or -strip_path in PrimePower) is the path to SAIF INSTANCE equivalent to the current design
  #   top_tb -> testbench, top -> my_design instantiation
  puts "Running read_saif"
  read_saif -input $SAIF_FILE -instance_name $INSTANCE_NAME -auto_map_names -scale 3.335
}
# Checking annotation rate 
#   A SAIF file contains synthesis-invariant points (seq-pin, primary ports and pre-instantiated cells (ICGs and macros)
#   and hierachical ports. Thereofe, users need to make sure that exist a high annotation rate in primary-input, seq-pin, 
#   no-func columns
redirect -file ../rpt/report_activity.driver.precompile.rpt -tee {report_activity -driver }

# Finding non-annotated RTL points
report_saif -missing -rtl -hier > ../rpt/report_saif.rtl.hier.missing.precompile.rpt

