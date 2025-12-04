#!/bin/bash

## PARAMETERS
prjfolder="$HOME/Documents/chiara/imputation"
outdir="$prjfolder/Analysis/goat/stats"
datafolder="data/goat"
dataset="CRE"

## SOFTWARE
plink="$HOME/Downloads/plink"
species="cow"

if [ ! -d $outdir ]; then
	echo "making folder $outdir"
	mkdir -p $outdir
fi	       

echo "run Plink to produce basic stats on genotypes"
$plink --$species --allow-extra-chr --bfile ${datafolder}/$dataset --freq --missing --het --out $outdir/$dataset

echo "DONE!"
