#!/bin/csh -f

module unload vcs
module unload verdi
module load verdi/2021.09-SP2-4
module load verdi/2021.09-SP2-3

set SOURCE_FILES = '../sim/top_tb.v \
                    ../rtl/my_design.v \
                    ../rtl/sum_acc.v \
                    ../rtl/flag_generator.v \
                    ../rtl/counter.v \
                    ../rtl/code_generator.v \
                    ../../ref/verilog/saed32nm_lvt.v'


set LOGS_DIR = '../logs'
set RESULTS_DIR = '../sim'

test -d work || mkdir work
test -d logs || mkdir logs
test -d results || mkdir results
rm -fr $LOGS_DIR/vcs_compile_rtl.log
rm -fr $LOGS_DIR/vcs_run_rtl.log

cd work

vcs -full64 -nc -kdb  +vcs+fsdbon -lca -debug_access+all  -sverilog $SOURCE_FILES |& tee $LOGS_DIR/vcs_compile_rtl.log
./simv +fsdb+all -saif_opt+upf_naming |& tee $LOGS_DIR/vcs_run_rtl.log
mv novas.fsdb $RESULTS_DIR/top_rtl.fsdb
mv top_rtl.saif $RESULTS_DIR/top_rtl.saif
fsdb2saif $RESULTS_DIR/top_rtl.fsdb -o $RESULTS_DIR/top_rtl.fsdb.saif -flatten_genhier


