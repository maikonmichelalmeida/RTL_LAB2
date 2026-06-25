# Task 1.5: To identify pre-exising clock gates
identify_clock_gating

# Task 1.6: Clock gating style settings
#
#   1.  The ICG library cell from pre-existing ICGs must be used for tool inserted ICG
#          Check library cell in pre-existing clock gating cells using:
#              get_lib_cell -of [all_clock_gates -origin pre_existing]
#   2.  The maximum of ICG stages is 4 (-num_stages 4)
#   3.  The minimum bitwidth for ICGs is 3 (-minimum_bitwidth 3)
#   4.  ICG Control point must be before the ICG latch (-control_point before)
#   5.  Pre-existing ICGs must be preserved. Their enabled condition should not be modified.
#          set_preserve_clock_gate [all_clock_gates ] -dont_modify_enable


set_clock_gating_style -num_stages 4 \
                       -minimum_bitwidth 3 \
                       -positive_edge_logic {integrated:CGLPPRX2_LVT} \
                       -negative_edge_logic  {integrated:CGLNPRX2_LVT} \
                       -control_point before

set_preserve_clock_gate [all_clock_gates ] -dont_modify_enable 

# Task 1.7 To insert clock gates through hierarchies
#set compile_clock_gating_through_hierarchy true
