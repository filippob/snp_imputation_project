#!/bin/bash

PLINK=~/Downloads/plink
DIR=data/pesco/SNP_array

cut -f1-2 -d' ' $DIR/CxEL.ped > tmp
sed -i 's/$/ CxEL/' tmp
awk '$4=$2' tmp > upd.ids
$PLINK --file $DIR/CxEL --allow-extra-chr --update-ids upd.ids --snps-only --geno 0.10 --mind 0.25 --bp-space 1 --make-bed --out $DIR/CxEL_filtered

cut -f1-2 -d' ' $DIR/DxP.ped > tmp
sed -i 's/$/ DxP/' tmp
awk '$4=$2' tmp > upd.ids
$PLINK --file $DIR/DxP --allow-extra-chr --update-ids upd.ids --snps-only --geno 0.10 --mind 0.25 --bp-space 1 --make-bed --out $DIR/DxP_filtered

cut -f1-2 -d' ' $DIR/pop001.ped > tmp
sed -i 's/$/ pop001/' tmp
awk '$4=$2' tmp > upd.ids
$PLINK --file $DIR/pop001 --allow-extra-chr --update-ids upd.ids --snps-only --geno 0.10 --mind 0.25 --bp-space 1 --make-bed --out $DIR/pop001_filtered

cut -f1-2 -d' ' $DIR/pop004.ped > tmp
sed -i 's/$/ pop004/' tmp
awk '$4=$2' tmp > upd.ids
$PLINK --file $DIR/pop004 --allow-extra-chr --update-ids upd.ids --snps-only --geno 0.10 --mind 0.25 --bp-space 1 --make-bed --out $DIR/pop004_filtered

cut -f1-2 -d' ' $DIR/pop014.ped > tmp
sed -i 's/$/ pop014/' tmp
awk '$4=$2' tmp > upd.ids
$PLINK --file $DIR/pop014 --allow-extra-chr --update-ids upd.ids --snps-only --geno 0.10 --mind 0.25 --bp-space 1 --make-bed --out $DIR/pop014_filtered

## combine
$PLINK --file $DIR/CxEL_filtered --allow-extra-chr --merge-list file.list --out $DIR/combined_18k
