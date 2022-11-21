#!/bin/sh

## script to run multiple times the imputation experiments

## PARAMETERS
datafolder="Analysis/goat/filtered_data"
n=5 ## n. of replicates to run

echo " - data folder is $datafolder"
echo " - the desired number of replicates per dataset is $n"

#for dataset in line1_filtered line2_filtered line3_filtered;
#for dataset in nss_filtered;
#for dataset in CxEL_filtered DxP_filtered pop001_filtered pop004_filtered;
for dataset in ALP_filtered ANG_filtered BRK_filtered BOE_filtered CRE_filtered LNR_filtered;
do
	echo "Analysing data from $dataset"
	for i in $(seq 1 $n);
	do	
		echo "running replicate $i on dataset $dataset"
		bash run_densityimputation.sh $datafolder/$dataset
	done
done

echo "DONE!"
