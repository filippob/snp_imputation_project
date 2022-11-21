#!/bin/sh

plink="/home/biscarinif/software/plink/plink"
prjfolder="$HOME/imputation"
inputfile="Analysis/goat/filtered_data/goat_filtered"
outdir="Analysis/goat/stats"

pairs=()

fname="$outdir/keep.fam"
#set -- CxEL DxP pop001 pop004
#set -- POP1 POP2 POP3
set -- ALP ANG BOE BRK CRE LNR
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

echo "DONE!"
