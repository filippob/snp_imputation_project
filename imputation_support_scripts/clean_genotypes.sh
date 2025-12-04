#!/bin/bash

## PARAMETERS
prjfolder="$HOME/Documents/chiara/imputation"
outdir="$prjfolder/data/cattle"
datafolder="data/cattle/THISISREALLYEVERYTHING"
dataset="PLINK_QC_PABLO_TUTTO"
selected_pops="breeds_to_keep"
chr1=1
chr_last=29
label="cattle"

## SOFTWARE
plink="$HOME/Downloads/plink"
species="cow"

if [ ! -d $outdir ]; then
	echo "making folder $outdir"
	mkdir -p $outdir
fi	       

if [ $species == "goat" ]; then
	species="cow"
fi

echo "Species is: $species"

echo "run Plink to clean genotype data"
$plink --$species --allow-extra-chr --bfile ${datafolder}/$dataset --chr ${chr1}-${chr_last} --keep-fam ${datafolder}/${selected_pops} --make-bed --out $outdir/${label}_cleaned

echo "DONE!"
