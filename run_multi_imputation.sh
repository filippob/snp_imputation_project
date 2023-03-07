#!/bin/sh

## script to run multiple times the imputation experiments

##########################################################
## PARAMETERS
##########################################################
datafolder="Analysis/goat/filtered_data"
pops="ANG CRE BRK"
target=""
sample_size=300
relationship="close" ## for across-population experiments
dataset="goat_filtered"
species="goat"
ld_array=""
exp_type="ACROSS" ## ACROOS, DENSITY, (GAP?)
#########################################################

n=1 ## n. of replicates to run

echo " - data folder is $datafolder"
echo " - the desired number of replicates per dataset is $n"
echo " - the type of relationships is $relationship"

## DENSITY IMP
if [ $exp_type == "DENSITY" ];
then
	echo "Running low-to-high density imputation experiments"

	#for dataset in line1_filtered line2_filtered line3_filtered;
	#for dataset in nss_filtered;
	#for dataset in CxEL_filtered DxP_filtered pop001_filtered pop004_filtered;
	#for dataset in ALP_filtered ANG_filtered BRK_filtered BOE_filtered CRE_filtered LNR_filtered;
fi

## ACROSS IMP
if [ $exp_type == "ACROSS" ];
then
        echo "Running across-population imputation experiments"
	echo "-----------"
	echo "SUBSET DATA"
	for pop in ${pops[@]}; do
		echo $pop >> $tmpname
		printf "$pop\n"
	done
	echo "---------"

	if [ $target == "" ];
	then

		for pop in ${pops[@]};
		do
			echo "Analysing data from $pop"
			for i in $(seq 1 $n);
			do	
				echo "running replicate $i on dataset $dataset"
				#bash run_densityimputation.sh $datafolder/$dataset
				bash run_acrossimputation.sh $datafolder/$dataset "$pops" "$pop" $sample_size $relationship $species $ld_array
			done
		done
	else
		echo "Analysing data from $target"
                for i in $(seq 1 $n);
                do
                	echo "running replicate $i on dataset $dataset"
                       	#bash run_densityimputation.sh $datafolder/$dataset
                        bash run_acrossimputation.sh $datafolder/$dataset "$pops" "$target" $sample_size $relationship $species $ld_array
               	done
	fi
fi

echo "DONE!"
