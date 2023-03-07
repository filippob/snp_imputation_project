#!/bin/sh

## script to run a single imputation experiment under the low-to-high density scenario
## bash run_acrossimputation.sh $datafolder/$dataset $pops "$pop" $sample_size $relationship $species $ld_array

## FROM THE COMMAND LINE
inputfile=$1
pops=($2) ## transform the input string into an array (space separated input string)
target_pop=$3
sample_size=$4
relationship=$5 ## close or distant, depennding on average pairwise Fst
species=$6
ld_array=$7 ## es. "/home/freeclimb/data/goat"

## SETUP
prjfolder="$HOME/imputation"
dataset=$species #name of dataset folder in Analysis/
outdir="Analysis/$dataset/across_imputation"
datafolder="$prjfolder/Analysis/$dataset/filtered_data"
repofolder="heterogeneousImputation"
configf="$prjfolder/$repofolder/config.sh"

if [ $species == "peach" ];
then
	
	## peach (or species where we do have a LD SNP array) ##
	ld_array=${ld_array}
else
	## maize (or species for which we generate random LD SNP arrays) ##
	nint=$((1 + $RANDOM % 10))
	ld_array="${datafolder}/${species}_bootstrap_${nint}.txt"
fi

## maize (or species for which we generate random LD SNP arrays) ##
nint=$((1 + $RANDOM % 10))
#ld_array="${datafolder}/goat_bootstrap_${nint}.txt"
##

## SOFTWARE
plink="$HOME/software/plink/plink"
species="cow"

## PARAMETERS
breed=$target_pop
nsize=$sample_size

if [ ! -d $outdir ]; then
        echo "making folder $outdir"
        mkdir -p $outdir
fi

#echo "subsetting these populations: $pops"
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

echo " - running the across-population imputation workflow"
bash $prjfolder/$repofolder/imputationAcrossBreeds_workflow.sh -f $outdir/$relationship -s $species -d ${ld_array} -n $nsize -b $breed -o $prjfolder/$outdir -c $configf

echo "DONE!"
