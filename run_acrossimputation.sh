#!/bin/sh

## script to run a single imputation experiment under the low-to-high density scenario

## SETUP
relationship="distant" ## close or distant, depennding on average pairwise Fst
prjfolder="$HOME/imputation"
dataset="peach" #name of dataset folder in Analysis/
outdir="Analysis/$dataset/across_imputation"
datafolder="$prjfolder/Analysis/$dataset/filtered_data"
repofolder="heterogeneousImputation"
configf="$prjfolder/$repofolder/config.sh"
inputfile=$1

## peach (or species where we do have a LD SNP array) ##
ld_array="/home/freeclimb/data/peach/SNP_array/snp_names.9k"

## maize (or species for which we generate random LD SNP arrays) ##
nint=$((1 + $RANDOM % 10))
#ld_array="${datafolder}/goat_bootstrap_${nint}.txt"
##

## SOFTWARE
plink="$HOME/software/plink/plink"
species="cow"

## PARAMETERS
pops=('CxEL' 'pop001' 'pop004')
breed='CxEL'
nsize=300

if [ ! -d $outdir ]; then
        echo "making folder $outdir"
        mkdir -p $outdir
fi

tmpname=$outdir/keep.fam

if [ -f $tmpname ]; then
        echo "removing folder $tmpname"
        rm $tmpname
fi


touch $tmpname
echo "-----------"
echo "SUBSET DATA"
for pop in ${pops[@]}; do
	echo $pop >> $tmpname
	printf "$pop\n"
done
echo "---------"	

$plink --cow --allow-extra-chr --bfile $prjfolder/$inputfile --keep-fam $tmpname --make-bed --out $outdir/$relationship

echo " - running the low-to-high density imputation workflow"
bash $prjfolder/$repofolder/imputationAcrossBreeds_workflow.sh -f $outdir/$relationship -s $species -d ${ld_array} -n $nsize -b $breed -o $prjfolder/$outdir -c $configf

echo "DONE!"
