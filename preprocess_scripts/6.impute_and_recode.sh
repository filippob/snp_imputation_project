#!/bin/sh

## script that uses Plink to filter, pseudoimpute and convert to SNP matrix

plink=/home/filippo/Downloads/plink
data_dir="/home/filippo/Documents/chiara/imputation/data/maize/cook_2012"
fname=maize

echo "Filter, (pseudo)impute and recode to 0/1/2"
echo "data folder is ${data_dir}"

$plink --bfile ${data_dir}/$fname --geno 0.05 --mind 0.10 --mac 4 --fill-missing-a2 --make-bed --out ${data_dir}/maize_imp
$plink --bfile ${data_dir}/maize_imp --recode A --out ${data_dir}/maize_imp

echo "DONE!"
