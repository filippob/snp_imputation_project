#!/bin/sh

## script to run multiple times the imputation experiments

## PARAMETERS
datafolder="Analysis/peach/filtered_data"
n=2 ## n. of replicates to run

echo " - data folder is $datafolder"
echo " - the desired number of replicates per dataset is $n"

for dataset in CxEL_filtered DxP_filtered pop001_filtered pop004_filtered;
do
	echo "Analysing data from $dataset"
	for i in $(seq 1 $n);
	do	
		echo "running replicate $i on dataset $dataset"
		bash run_densityimputation.sh $datafolder/$dataset
	done
done

echo "DONE!"
