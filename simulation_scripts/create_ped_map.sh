#!/bin/bash

prjfolder="$HOME/Documents/chiara/imputation/simulation"
expfolder="r_sim1"
mapfile="lm_mrk.txt"
pedfile="Line 1_mrk_001.txt"

cd $prjfolder

## map file
bsname="${mapfile%.*}"
tail -n +2 ${expfolder}/${mapfile} | awk '{print $2, $1, 0, $3}' > ${expfolder}/${bsname}.map

## ped file
for j in {1..3};
	do
	fname="Line ${j}_mrk_001.txt"
	echo $fname
	tail -n +2 ${expfolder}/"${fname}" | awk '{printf "POP " $1; printf " 0 0 0 -9 " ; for(i=2; i<=NF; i++) printf $i" "; print""}' > "${expfolder}/line${j}.ped"
done
