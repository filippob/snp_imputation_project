#!/bin/bash

prjfolder="$HOME/Documents/chiara/imputation/simulation"

cd $prjfolder

echo " - running simulations ... "
./simulation_software/QMSim2 paramfiles/sim1.prm -o

echo "DONE!"
