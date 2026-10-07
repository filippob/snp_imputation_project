# snp_imputation_project
support scripts and material for the imputation project (diploid genomes, multiple species, multiple scenarios)

### multiple species
- goats
- cattle
- sheep
- peach
- maize
- simulated data

### multiple scenarios
1. gap-filling: impute residual missing SNP genotypes in the *(n x m)* matrix of SNP genotypes (n samples, m SNPs) (fill in the blanks)
2. density-imputation: impute from low density (LD) to high density (HD) SNP data (portion of samples with LD genotypes, 
portion of samples with HD genotypes; the result is all samples with HD genotypes
3. across-imputation: impute from one (or more) populations to another one (training: all other species; missing genotypes: the target species)
4. mixed-imputation: impute residual missing SNP genotypes in a mixed datasets with multiple populations together

---

## Minimum workflow
1. [clean_genotypes.sh](imputation_support_scripts/clean_genotypes.sh): takes in input the raw data and keeps the desired populations/breeds and chromosomes (e.g. exclude sex chromosomes)
      - **sheep**: SNP50_Breedv1.[bim/bed/fam] $\rightarrow$ sheep_cleaned.[bim/bed/fam]
      - **maize**: SNP55K_maize282.[bim/bed/fam]* $\rightarrow$ maize_cleaned.[bim/bed/fam]
3. [filter_genotypes.sh](imputation_support_scripts/filter_genotypes.sh):


*the binary Plink fileset `SNP55K_maize282` was obtained from the raw data files (single hapmap files for each chromosome) using custom scripts (1.hapmap2vcf.sh; 2.merge_vcf.sh; 4.vcf2plink.sh)
