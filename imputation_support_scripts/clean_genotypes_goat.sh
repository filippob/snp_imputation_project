#!/bin/bash

## PARAMETERS
prjfolder="$HOME/Documents/chiara/imputation"
outdir="$prjfolder/data/goat/"
datafolder="data/goat/"
dataset="goat"
selected_pops="breeds_to_keep"

## SOFTWARE
plink="$HOME/Downloads/plink"
species="goat"

if [ ! -d $outdir ]; then
	echo "making folder $outdir"
	mkdir -p $outdir
fi	       

if [ $species == "goat" ]; then
	species="cow"
fi

echo "Species is: $species"

echo "run Plink to clean genotype data"
$plink --$species --allow-extra-chr --bfile ${datafolder}/$dataset --chr 1-29 --keep-fam ${datafolder}/${selected_pops} --make-bed --out $outdir/${dataset}_cleaned

echo "DONE!"
