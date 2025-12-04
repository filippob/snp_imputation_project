#!/bin/bash

## SETUP
prjfolder="$HOME/Documents/chiara/imputation"
outdir="$prjfolder/data/goat/filtered_data"
datafolder="data/goat"
dataset="LNR"

## SOFTWARE
plink="$HOME/Downloads/plink"
species="cow"

## PARAMETERS
maf=0.01
mac=4
geno=0.05
mind=0.20

if [ ! -d $outdir ]; then
	echo "making folder $outdir"
	mkdir -p $outdir
fi	       

echo "run Plink to produce basic stats on genotypes"
$plink --$species --allow-extra-chr --bfile ${datafolder}/$dataset --maf $maf --mac $mac --mind $mind --geno $geno --bp-space 1 --snps-only 'just-acgt' --make-bed --out $outdir/${dataset}_filtered

echo "DONE!"
