#!/bin/bash

## SETUP
prjfolder="$HOME/imputation"
outdir="$prjfolder/Analysis/peach/filtered_data"
datafolder="/home/freeclimb/data/peach/SNP_array"
dataset="pop004_filtered"

## SOFTWARE
plink="$HOME/software/plink/plink"
species="cow"

## PARAMETERS
maf=0.01
mac=0
geno=0.2
mind=0.2

if [ ! -d $outdir ]; then
	echo "making folder $outdir"
	mkdir -p $outdir
fi	       

echo "run Plink to produce basic stats on genotypes"
$plink --$species --allow-extra-chr --bfile ${datafolder}/$dataset --maf $maf --mac $mac --mind $mind --geno $geno --bp-space 1 --snps-only 'just-acgt' --make-bed --out $outdir/$dataset

echo "DONE!"
