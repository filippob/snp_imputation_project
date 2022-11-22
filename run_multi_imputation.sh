#!/bin/sh

## script to run multiple times the imputation experiments

## PARAMETERS
datafolder="Analysis/peach/filtered_data"
pops="CxEL pop001 DxP"
relationship="distant"
dataset="combined_18k_filtered"

n=1 ## n. of replicates to run

echo " - data folder is $datafolder"
echo " - the desired number of replicates per dataset is $n"

## DENSITY IMP
#for dataset in line1_filtered line2_filtered line3_filtered;
#for dataset in nss_filtered;
#for dataset in CxEL_filtered DxP_filtered pop001_filtered pop004_filtered;
#for dataset in ALP_filtered ANG_filtered BRK_filtered BOE_filtered CRE_filtered LNR_filtered;

## ACROSS IMP
for pop in "CxEL pop001 DxP" "CxEL pop004 DxP" "CxEL pop001 pop004";
do
	echo "Analysing data from $pop"
	for i in $(seq 1 $n);
	do	
		echo "running replicate $i on dataset $dataset"
		#bash run_densityimputation.sh $datafolder/$dataset
		bash run_acrossimputation.sh $datafolder/$dataset "$pop" $relationship
	done
done

echo "DONE!"
