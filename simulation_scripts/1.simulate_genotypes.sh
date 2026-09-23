#!/bin/bash

prjfolder="$HOME/Documents/chiara/imputation/simulation"
repo="$HOME/Documents/chiara/imputation/snp_imputation_project/simulation_scripts"
cd $prjfolder

echo " - running simulations ... "
$repo/simulation_software/QMSim2 paramfiles/sim1.prm -o

echo "DONE!"
