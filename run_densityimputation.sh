#!/bin/sh

## script to run a single imputation experiment under the low-to-high density scenario

## SETUP
prjfolder="$HOME/imputation"
outdir="$prjfolder/Analysis/peach/density_imputation"
datafolder="$prjfolder/Analysis/peach/filtered_data"
#dataset=$1
inputfile=$1
repofolder="heterogeneousImputation"
ld_array="/home/freeclimb/data/peach/SNP_array/snp_names.9k"
configf="$prjfolder/$repofolder/config.sh"

## SOFTWARE
plink="$HOME/software/plink/plink"
species="cow"

## PARAMETERS
nsize=100
ldsize=20

if [ ! -d $outdir ]; then
        echo "making folder $outdir"
        mkdir -p $outdir
fi

echo " - running the low-to-high density imputation workflow"
bash $prjfolder/$repofolder/imputationDensity_workflow.sh -f $inputfile -s $species -d ${ld_array} -n 100 -l 20 -o $outdir -c $configf

echo "DONE!"
