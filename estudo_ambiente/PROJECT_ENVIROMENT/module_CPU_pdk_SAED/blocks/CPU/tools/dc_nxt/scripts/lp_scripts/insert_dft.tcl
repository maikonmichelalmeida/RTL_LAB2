
#############################################################################
# DFT Signal Type Definitions
set_dft_signal -view exist -type ScanClock -port clk -timing {45 55}
create_port -dir in SE
set_dft_signal -view spec -type ScanEnable -port SE -active_state 1
set chains 2
for {set i 0} {$i < $chains} {incr i} {
    create_port -dir in SI[$i]
    puts "set_dft_signal -view spec -type ScanDataIn -port SI[$i]"
    set_dft_signal -view spec -type ScanDataIn -port SI[$i]
    create_port -dir out SO[$i]
    puts "set_dft_signal -view spec -type ScanDataOut -port SO[$i]"
    set_dft_signal -view spec -type ScanDataOut -port SO[$i]
}

#############################################################################
# DFT Configuration
set_scan_configuration -chain_count ${chains}

#############################################################################
# DFT Test Protocol Creation
create_test_protocol

#############################################################################
# DFT Insertion
dft_drc
redirect -file ../rpt/dft_drc_configured.rpt { dft_drc -verbose }
redirect -file ../rpt/scan_config.rpt { report_scan_configuration -test_mode all }
redirect -file ../rpt/compression_config.rpt { report_scan_compression_configuration -test_mode all }
redirect -file ../rpt/report_dft_insertion_config.preview_dft.rpt { report_dft_insertion_configuration }
redirect -file ../rpt/dft_config.rpt { report_dft_configuration }
redirect -file ../rpt/preview_dft.rpt { preview_dft -show all -test_points all }

insert_dft
#############################################################################
