#!/bin/csh -f

module unload syn
module load syn/2022.03-SP3 # dcnxt

mkdir -p work
mkdir -p logs
mkdir -p results


pushd ./work

dcnxt_shell -no_home -topo -f ../scripts/dc.tcl | tee  ../logs/dc.log


popd

