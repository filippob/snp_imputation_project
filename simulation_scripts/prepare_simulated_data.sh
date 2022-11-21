#!/bin/sh

## this script takes in input the Plink maize files from https://datacommons.cyverse.org/browse/iplant/home/shared/commons_repo/curated/Cook_KernelArchitecturePlantPhys_Feb2012 
## and metadata from https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fj.1365-313X.2005.02591.x&file=TPJ_2591_sm_tableS1.doc
## and update family IDs in the Plink binary files to allow for our experiments of imputation in heterogeneous populations

plink=$HOME/Downloads/plink
data_folder="simulation/r_sim1"
mapf="${data_folder}/lm_mrk.map"
pops="ts,nss,mixed"
mind=0.25
geno=0.20

echo "update pop information (pop1 .. pop3)"
for n in {1..3}; do
	echo $n
	sed -i "s/POP/POP${n}/g" ${data_folder}/line${n}_recoded.ped
	$plink --ped ${data_folder}/line${n}_recoded.ped --map ${mapf} --mind $mind --geno $geno --make-bed --out ${data_folder}/line${n}
done

echo " - merge individual plink files"

## combine
$plink --bfile ${data_folder}/line1 --bmerge ${data_folder}/line2 --make-bed --out ${data_folder}/temp
$plink --bfile ${data_folder}/temp --bmerge ${data_folder}/line3 --make-bed --out ${data_folder}/simdata

echo "cleaning up: removing temp files"
rm ${data_folder}/temp*

echo "DONE!!"
