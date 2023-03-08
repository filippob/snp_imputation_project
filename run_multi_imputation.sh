#!/bin/sh

## script to run multiple times the imputation experiments


## !! TO REMEMBER !! ##################################
# check config.sh in heterogenousImputation
# 1) set label (AGROSS, GAP, DENSITY, MIXED)
# 2) set singularity container if running through slurm
#######################################################

##########################################################
## PARAMETERS
##########################################################
datafolder="Analysis/maize/filtered_data"
pops="nss ts"
target="ts"
sample_size=100
relationship="distant" ## for across-population experiments
dataset="maize_filtered" ## peach: combined_18k_filtered; goat: goat_filtered etc.
species="maize"
ld_array=""
#ld_array="/home/freeclimb/data/peach/SNP_array/snp_names.9k"
exp_type="ACROSS" ## ACROSS, DENSITY, (GAP?)
#########################################################

n=1 ## n. of replicates to run

echo " - data folder is $datafolder"
echo " - the desired number of replicates per dataset is $n"
echo " - the type of relationships is $relationship"

## DENSITY IMP
if [[ "$exp_type" == "DENSITY" ]];
then
	echo "Running low-to-high density imputation experiments"

	#for dataset in line1_filtered line2_filtered line3_filtered;
	#for dataset in nss_filtered;
	#for dataset in CxEL_filtered DxP_filtered pop001_filtered pop004_filtered;
	#for dataset in ALP_filtered ANG_filtered BRK_filtered BOE_filtered CRE_filtered LNR_filtered;
fi

## ACROSS IMP
if [[ "${exp_type}" == "ACROSS" ]];
then
        echo "Running across-population imputation experiments"
	echo "-----------"
	#echo "SUBSET DATA"
	#for pop in ${pops[@]}; do
	#	echo $pop >> $tmpname
	#	printf "$pop\n"
	#done
	echo "---------"

	if [[ "$target" == "" ]];
	then
		echo "Running analysis with rotating target (unspecified)"
		for pop in ${pops[@]};
		do
			echo "Analysing data from $pop"
			for i in $(seq 1 $n);
			do	
				echo "running replicate $i on dataset $dataset"
				#bash run_densityimputation.sh $datafolder/$dataset
				bash run_acrossimputation.sh $datafolder/$dataset "$pops" $pop $sample_size $relationship $species $ld_array
				#echo "run_acrossimputation.sh $datafolder/$dataset '$pops' $pop $sample_size $relationship $species $ld_array"
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
