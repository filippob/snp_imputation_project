#!/bin/sh

## script to run a single imputation experiment under the mixed gap-imputation
## heterogeneous dataset of mixed populations (e.g. multiple breeds) where residual gap missing data are to be imputed

## FROM THE COMMAND LINE
inputfile=$1
missing_rate=$2
sample_size=$3
species=$4

## SETUP
prjfolder="$HOME/Documents/chiara/imputation"
dataset=$species #name of dataset folder in Analysis/
outdir="$prjfolder/Analysis/$dataset/mixed_imputation"
datafolder="$prjfolder/Analysis/$dataset/filtered_data"
repofolder="heterogeneousImputation"
configf="$prjfolder/$repofolder/config.sh"
inputfile=$1

## SOFTWARE
plink="$HOME/software/plink/plink"
#species="cow"

## PARAMETERS
nsize=$sample_size
miss_inject=$missing_rate

if [ ! -d $outdir ]; then
        echo "making folder $outdir"
        mkdir -p $outdir
fi

echo "Input species is; $species"

if [ "$species" != "cow" ] && [ "$species" != "sheep" ]; then
	species="cow"
fi

echo "Plink species is $species"

echo " - running the low-to-high density imputation workflow"
bash $prjfolder/$repofolder/imputationWorkflow.sh -f $inputfile -s $species -p $miss_inject -n $nsize -o $outdir -c $configf

echo "DONE!"
