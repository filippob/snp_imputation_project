#!/bin/sh

## script that uses bcftools to combine multiple compressed and indexed vcf files

data_dir="/home/filippo/Documents/chiara/imputation/data/maize/cook_2012"

echo "concatenate multiple per-chromosome vcf files into one combined vcf file"
echo "data folder is ${data_dir}"

cd ${data_dir}
ls SNP55K_maize282_AGPv1_chr*.vcf.gz > file_list
bcftools concat -f file_list -o SNP55K_maize282_AGPv1_combined.vcf

echo "DONE!"
