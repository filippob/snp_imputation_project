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
