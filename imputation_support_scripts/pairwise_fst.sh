#!/bin/sh

plink="$HOME/Downloads/plink"
prjfolder="$HOME/Documents/chiara/imputation"
inputfile="Analysis/simdata/filtered_data/combined_18k_filtered"
outdir="Analysis/peach/stats"

pairs=()

fname="$outdir/keep.fam"
set -- CxEL DxP pop001 pop004
for a; do
    shift
    for b; do
        printf "%s vs %s\n" "$a" "$b"
	echo $a > $fname
	echo $b >> $fname
	distname="${a}_${b}_dist"
	$plink --cow --allow-extra-chr --bfile $prjfolder/$inputfile --keep-fam $fname --family --fst --out $outdir/$distname
    done
done

#$plink --cow --allow-extra-chr --bfile $prjfolder/$inputfile --family --fst --out $outdir/dist

