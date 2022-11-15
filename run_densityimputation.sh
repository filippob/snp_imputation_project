#!/bin/sh

## script to run a single imputation experiment under the low-to-high density scenario

## SETUP
prjfolder="$HOME/imputation"
outdir="$prjfolder/Analysis/maize/density_imputation"
datafolder="$prjfolder/Analysis/maize/filtered_data"
configf="$prjfolder/$repofolder/config.sh"
#dataset=$1
inputfile=$1
repofolder="heterogeneousImputation"

## peach (or species where we do have a LD SNP array) ##
#ld_array="/home/freeclimb/data/peach/SNP_array/snp_names.9k"

## maize (or species for which we generate random LD SNP arrays) ##
nint=$((1 + $RANDOM % 10))
ld_array="${datafolder}/maize_bootstrap_${nint}.txt"
##

## SOFTWARE
plink="$HOME/software/plink/plink"
species="cow"

## PARAMETERS
nsize=100
ldsize=10

if [ ! -d $outdir ]; then
        echo "making folder $outdir"
        mkdir -p $outdir
fi

echo " - running the low-to-high density imputation workflow"
bash $prjfolder/$repofolder/imputationDensity_workflow.sh -f $inputfile -s $species -d ${ld_array} -n $nsize -l $ldsize -o $outdir -c $configf

echo "DONE!"
