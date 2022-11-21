#!/bin/bash

prjfolder="$HOME/Documents/chiara/imputation/simulation"
expfolder="r_sim1"
mapfile="lm_mrk_001.txt"

cd $prjfolder

echo " - preprocessing simulated data (multiplying marker position by power of 10)"
tail -n +2 ${expfolder}/$mapfile > temp
awk '{print $3*100000}' temp > pos
awk '{print $1 "   " $2}' temp > tmp
paste -d'\t' tmp pos > temp
echo -e "ID\tChr\tPosition" | cat - temp > $expfolder/lm_mrk.txt

rm temp pos tmp

echo "DONE!!"
