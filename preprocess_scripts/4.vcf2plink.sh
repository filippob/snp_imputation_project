#!/bin/sh

## script that uses Plink to convert vcf to plink

plink=/home/filippo/Downloads/plink
data_dir="/home/filippo/Documents/chiara/imputation/data/maize/cook_2012"

echo "Convert VCF to Plink binary files"
## paper below at https://onlinelibrary.wiley.com/doi/10.1111/j.1365-313X.2005.02591.x
echo "updating family info to align with Flint-Garcia et al. 2005 (metadata)"
echo "data folder is ${data_dir}"

$plink --vcf ${data_dir}/SNP55K_maize282_AGPv1_combined.vcf --update-ids ${data_dir}/upd_ids.csv --make-bed --out ${data_dir}/SNP55K_maize282


echo "DONE!"
