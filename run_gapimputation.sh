#!/bin/sh

## script to run a single imputation experiment under the gap-imputation scenario
## dataset of simple populations (e.g. single breed) where residual gap missing data are to be imputed

## FROM THE COMMAND LINE
inputfile=$1
missing_rate=$2
sample_size=$3
species=$4

## SETUP
prjfolder="$HOME/Documents/chiara/imputation"
dataset=$species #name of dataset folder in Analysis/
outdir="$prjfolder/Analysis/$dataset/gap_imputation"
datafolder="$prjfolder/data/$dataset/filtered_data"
repofolder="heterogeneousImputation"
configf="$prjfolder/$repofolder/config.sh"
inputfile=$1

## SOFTWARE
plink="$HOME/software/plink/plink"
#species="cow"

## PARAMETERS
nsize=$sample_size
miss_inject=$missing_rate

echo "Input species is; $species"

if [ "$species" != "cow" ] || [ "$species" != "sheep" ]; then
	species="cow"
fi

echo "Plink species is $species"

if [ ! -d $outdir ]; then
        echo "making folder $outdir"
        mkdir -p $outdir
fi

echo " - running the low-to-high density imputation workflow"
bash $prjfolder/$repofolder/imputationWorkflow.sh -f $inputfile -s $species -p $miss_inject -n $nsize -o $outdir -c $configf

echo "DONE!"
