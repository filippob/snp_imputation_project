#!/bin/bash

## PARAMETERS
prjfolder="$HOME/Documents/chiara/imputation"
outdir="$prjfolder/data/sheep/"
datafolder="$prjfolder/data/sheep/"
dataset="sheep_cleaned"
selected_pops="breeds_to_keep"

## SOFTWARE
plink="$HOME/Downloads/plink"
species="sheep"

### OUTDIR
if [ ! -d $outdir ]; then
	echo "making folder $outdir"
	mkdir -p $outdir
fi	       

### SPECIES
echo "Input species is: $species"

if [ $species == "goat" ]; then
	species="cow"
fi

echo "Plink species is: $species"
###########

### FOR LOOP ####
while read -r line
do
    
	echo "$line"
	touch $outdir/temp
	echo $line > $outdir/temp
    	echo "run Plink to clean genotype data"
    	$plink --$species --allow-extra-chr --bfile ${datafolder}/$dataset --keep-fam ${outdir}/temp --make-bed --out $outdir/$line

done < ${datafolder}/${selected_pops}


echo "DONE!"

