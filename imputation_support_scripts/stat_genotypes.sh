#!/bin/bash

## PARAMETERS
prjfolder="$HOME/imputation"
outdir="$prjfolder/Analysis/goat/stats"
datafolder="/home/freeclimb/data/goat"
dataset="ANG"

## SOFTWARE
plink="$HOME/software/plink/plink"
species="cow"

if [ ! -d $outdir ]; then
	echo "making folder $outdir"
	mkdir -p $outdir
fi	       

echo "run Plink to produce basic stats on genotypes"
$plink --$species --allow-extra-chr --bfile ${datafolder}/$dataset --freq --missing --out $outdir/$dataset

echo "DONE!"
