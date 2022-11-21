#!/bin/sh

## script that uses tassel5 to convert hapmap SNP files to vcf files

tassel=/home/filippo/TASSEL5/run_pipeline.pl
data_dir="/home/filippo/Documents/chiara/imputation/data/maize/cook_2012"

echo "start converting hapmap files to vcf"
echo "data folder is ${data_dir}"

for i in {0..10}
do
	echo " - now converting file $i to VCF"
	$tassel -h ${data_dir}/SNP55K_maize282_AGPv1_chr${i}_20100513.hmp.txt -export ${data_dir}/SNP55K_maize282_AGPv1_chr${i}_20100513.vcf -exportType VCF
	bgzip ${data_dir}/SNP55K_maize282_AGPv1_chr${i}_20100513.vcf
	tabix -f -p vcf ${data_dir}/SNP55K_maize282_AGPv1_chr${i}_20100513.vcf.gz
done

echo "DONE!"
