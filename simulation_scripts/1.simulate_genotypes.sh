#!/bin/bash

prjfolder="$HOME/Documents/chiara/imputation/simulation"

cd $prjfolder

echo " - running simulations ... "
./QMSim2_Linux/QMSim paramfiles/sim1.prm -o

echo "DONE!"
