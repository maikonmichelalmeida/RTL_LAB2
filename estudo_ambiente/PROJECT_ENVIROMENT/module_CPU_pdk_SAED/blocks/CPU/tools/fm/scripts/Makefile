# Aux Variables
SRC_TB=../sim
SRC_RTL=../rtl_store_I
SRC=$(filter-out %_tb.v, $(wildcard $(SRC_RTL)/*.*v)) 
VCS_OPT=-sverilog -debug_access+all -cm line+cond+fsm+tgl+branch -cm_dir ./cov_work -kdb +vcs+fsdbon
VCS_RUN_OPT="+fsdb+all"

###########
# Targets
###########
# Simulation
simv.%: $(SRC) 
	test -d models || ln -s ../models .
	vcs $(VCS_OPT) $(SRC_TB)/$(@:simv.%=%)_tb.sv $(SRC) -o $@
sim: setup
	cd work_sim && make -f ../Makefile simv.top
	cd work_sim && ./simv.top $(VCS_RUN_OPT) |& tee ../logs/sim.log
	cd work_sim && cp novas.fsdb ../outputs/top_rtl.fsdb
saif: sim
	cd work_sim && fsdb2saif ../outputs/top_rtl.fsdb -o ../outputs/top_rtl.fsdb.saif

# All variants synthesis and place-and-route
all_impl: syn pnr syn_ppa pnr_ppa syn_ppa2 pnr_ppa2
	@echo "All implementations complete:"
	@echo "  Base:  outputs/     -> reports/"
	@echo "  PPA:   outputs_ppa/ -> reports_ppa/"
	@echo "  PPA2:  outputs_ppa2/ -> reports_ppa2/"
all_signoff: signoff signoff_ppa signoff_ppa2
	@echo "Signoff for All Variants Completed:"
	@echo "  Base:  reports/pt"
	@echo "  PPA:   reports_ppa/pt"
	@echo "  PPA2:  reports_ppa2/pt"

# Baseline Implementation Targets
#syn_test: saif setup
syn: saif setup
	cd work_syn && dc_shell -topo -f ../scripts/dc.tcl | tee -i ../logs/dc.log
fm: 
	cd work_fm && fm_shell -f ../scripts/fm.tcl | tee -i ../logs/fm.log	
pnr: outputs/top.ddc setup
	cd work_pnr && icc2_shell -gui -f ../scripts/icc2.tcl | tee -i ../logs/icc2.log
signoff: phys_extract tim_analysis 
	@echo "Signoff flow complete for outputs -> reports"
phys_extract: 
	@echo "Generating SPEF from LEF/DEF (outputs -> reports)..."
	test -d work_signoff || mkdir work_signoff
	@echo "Generating StarRC command file from template..."
	sed 's|__WORK_DIR__|../outputs|g' scripts/starrc.cmd.template > work_signoff/starrc.cmd
	cd work_signoff && \
		OUTPUT_DIR="../outputs" \
		REPORT_DIR="../reports" \
		StarXtract starrc.cmd | tee ../logs/starrc.log
tim_analysis: ./work_signoff/TOP_WIDTH8.SPEF.nominal
	@echo "Generating timing reports (outputs -> reports/pt)..."
	test -d reports/pt || mkdir -p reports/pt
	cd work_signoff && \
		OUTPUT_DIR="../outputs" \
		REPORT_DIR="../reports" \
		pt_shell -f ../scripts/pt.tcl | tee ../logs/pt.log

# Pattern-based PPA targets - supports syn_ppa, syn_ppa2, syn_ppa3, etc.
syn_%: saif setup
	test -d reports_$* || mkdir reports_$*
	test -d outputs_$* || mkdir outputs_$*
	cd work_syn && dc_shell -topo -f ../scripts/dc.$*.tcl | tee -i ../logs/dc.$*.log
outputs_%/top.ddc: outputs/top_rtl.fsdb.saif
	test -d reports_$* || mkdir reports_$*
	test -d outputs_$* || mkdir outputs_$*
	cd work_syn && dc_shell -topo -f ../scripts/dc.$*.tcl | tee -i ../logs/dc.$*.log
pnr_%: outputs_%/top.ddc
	echo "Run icc2 $*"
	cd work_pnr && icc2_shell -f ../scripts/icc2.$*.tcl | tee -i ../logs/icc2.$*.log
signoff_%:
	@echo "Starting signoff flow for outputs_$* -> reports_$*"
	$(MAKE) phys_extract_$*
	$(MAKE) tim_analysis_$*
	@echo "Signoff flow complete for outputs_$* -> reports_$*"
phys_extract_%:
	@echo "Generating SPEF from LEF/DEF (outputs_$* -> reports_$*)..."
	test -d work_signoff_$* || mkdir work_signoff_$*
	@echo "Generating StarRC command file from template..."
	sed 's|__WORK_DIR__|../outputs_$*|g' scripts/starrc.cmd.template > work_signoff_$*/starrc.cmd
	cd work_signoff_$* && \
		OUTPUT_DIR="../outputs_$*" \
		REPORT_DIR="../reports_$*" \
		StarXtract starrc.cmd | tee ../logs/starrc_$*.log
tim_analysis_%:
	@echo "Generating timing reports (outputs_$* -> reports_$*/pt)..."
	test -d reports_$*/pt || mkdir -p reports_$*/pt
	cd work_signoff_$* && \
		OUTPUT_DIR="../outputs_$*" \
		REPORT_DIR="../reports_$*" \
		pt_shell -f ../scripts/pt.tcl | tee ../logs/pt_$*.log

# Timing Analysis and Reporting 
timing_report:
	@echo "Generating Timing Convergence Report..."
	@csh scripts/gpt_scripts/timing_report.csh reports
	@echo ""
	@if [ -f "reports/pt/pt.timing.rpt" ]; then \
		echo "=== SIGNOFF TIMING (PrimeTime) ==="; \
		echo "Critical Path Slack: `grep -E 'slack.*[0-9]' reports/pt/pt.timing.rpt | head -1 | awk '{print $$NF}'` ns"; \
		echo "Report: reports/pt/pt.timing.rpt"; \
	else \
		echo "No signoff timing available (run 'make signoff' first)"; \
	fi

timing_report_%:
	@echo "Generating $* Timing Convergence Report..."
	@csh scripts/gpt_scripts/timing_report.csh reports_$*
	@echo ""
	@if [ -f "reports_$*/pt/pt.timing.rpt" ]; then \
		echo "=== SIGNOFF TIMING (PrimeTime) ==="; \
		echo "Critical Path Slack: `grep -E 'slack.*[0-9]' reports_$*/pt/pt.timing.rpt | head -1 | awk '{print $$NF}'` ns"; \
		echo "Report: reports_$*/pt/pt.timing.rpt"; \
	else \
		echo "No signoff timing available (run 'make signoff_$*' first)"; \
	fi
timing_plot_ascii:
	@echo "Generating ASCII timing plot..."
	@csh scripts/gpt_scripts/plot_timing_ascii.csh reports
timing_plot:
	@echo "Generating timing convergence plot..."
	@csh scripts/gpt_scripts/plot_timing_gnuplot.csh reports
timing_plot_ppa:
	@echo "Generating Standard vs PPA flow comparison plot..."
	@if [ -d "reports_ppa" ]; then \
		csh scripts/gpt_scripts/plot_timing_comparison.csh reports reports_ppa; \
	else \
		echo "PPA reports not found, running single flow analysis..."; \
		csh scripts/gpt_scripts/plot_timing_comparison.csh reports; \
	fi

# Power analysis targets
power_extract:
	@echo "Extracting power data from all reports..."
	@csh scripts/gpt_scripts/extract_power_data.csh

power_report:
	@echo "Generating power analysis summary..."
	@csh scripts/gpt_scripts/generate_power_summary.csh

power_analysis: power_extract power_report
	@echo "Complete power analysis generated in docs/Power_Analysis_Summary.md"

# Auxiliary targets
setup:
	test -d work_sim || mkdir work_sim
	test -d work_syn || mkdir work_syn
	test -d work_fm || mkdir work_fm
	test -d work_pnr || mkdir work_pnr
	test -d reports || mkdir reports 
	test -d outputs || mkdir outputs 
	test -d logs || mkdir logs
	test -d work_signoff || mkdir work_signoff

setup_%:
	test -d work_sim || mkdir work_sim
	test -d work_syn || mkdir work_syn
	test -d work_fm || mkdir work_fm
	test -d work_pnr || mkdir work_pnr
	test -d reports_$* || mkdir reports_$* 
	test -d outputs_$* || mkdir outputs_$* 
	test -d logs || mkdir logs
	test -d work_signoff_$* || mkdir work_signoff_$* 

clean:
	rm logs work* reports* outputs* session* -fr

clean_signoff:
	rm work_signoff* -fr
	@echo "Signoff work directories cleaned"

clean_%:
	rm work_signoff_$* reports_$*/pt outputs_$* logs/*.$*.log -fr
	@echo "Cleaned $* flow artifacts"

# Additional convenience targets
help:
	@echo "CPU Design Flow Targets:"
	@echo ""
	@echo "Complete Flows:"
	@echo "  all_impl        - Run syn+pnr for all variants (base, ppa, ppa2)"
	@echo "  syn + pnr       - Standard implementation flow"
	@echo "  syn_ppa + pnr_ppa - PPA variant implementation flow"
	@echo ""
	@echo "Individual Steps:"
	@echo "  sim             - RTL simulation"
	@echo "  syn / syn_*     - Synthesis (any variant)"
	@echo "  pnr / pnr_*     - Place and route (any variant)"
	@echo ""
	@echo "Signoff Analysis:"
	@echo "  signoff / signoff_* - Complete signoff flow (SPEF + timing)"
	@echo ""
	@echo "For signoff help: make signoff_help"

signoff_help:
	@echo "Available signoff targets:"
	@echo "  signoff         - Standard flow (outputs/ -> reports/)"
	@echo "  signoff_ppa     - PPA flow (outputs_ppa/ -> reports_ppa/)"  
	@echo "  signoff_ppa2    - PPA2 flow (outputs_ppa2/ -> reports_ppa2/)"
	@echo "  signoff_*       - Any variant flow (outputs_*/ -> reports_*/)"
	@echo ""
	@echo "Directory mapping:"
	@echo "  INPUT:  outputs[_variant]/"
	@echo "  OUTPUT: reports[_variant]/pt/"
	@echo "  WORK:   work_signoff[_variant]/"
