#!/bin/sh

## script that uses Plink to compute descriptive stats on the combined vcf file

plink=/home/filippo/Downloads/plink
data_dir="/home/filippo/Documents/chiara/imputation/data/maize/cook_2012"

echo "Calculate descriptive stats"
echo "data folder is ${data_dir}"

$plink --vcf ${data_dir}/SNP55K_maize282_AGPv1_combined.vcf --missing --freq --out ${data_dir}/SNP55K_maize

echo "DONE!"
