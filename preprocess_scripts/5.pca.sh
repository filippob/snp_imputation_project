#!/bin/sh

## script that uses Plink to extract n Principal Components

plink=/home/filippo/Downloads/plink
data_dir="/home/filippo/Documents/chiara/imputation/data/maize/cook_2012"
fname=maize ## previously SNP55K_maize282

echo "Calculate PCA"
echo "data folder is ${data_dir}"

$plink --bfile ${data_dir}/SNP55K_maize282 --pca --out ${data_dir}/$fname
$plink --bfile ${data_dir}/SNP55K_maize282 --make-rel square gz --out ${data_dir}/$fname

echo "DONE!"
