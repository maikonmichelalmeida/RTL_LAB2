#!/bin/csh -f

module unload pt/2022.03-SP3
module load pt/2022.03-SP3

mkdir -p work
mkdir -p logs
mkdir -p reports
mkdir -p results

pushd ./work

pwr_shell -f ../scripts/pwr.tcl | tee ../logs/pwr.log

popd

