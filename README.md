# snp_imputation_project
support scripts and material for the imputation project (diploid genomes, multiple species, multiple scenarios)

### multiple species (and multiple subpopulations within)
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

### Preprocessing

1. [clean_genotypes.sh](imputation_support_scripts/clean_genotypes.sh): takes in input the raw data and keeps the desired populations/breeds and chromosomes (e.g. exclude sex chromosomes)
      - **sheep**: SNP50_Breedv1.[bim/bed/fam] $\rightarrow$ sheep_cleaned.[bim/bed/fam]
      - **goat**: goat.[bim/bed/fam] $\rightarrow$ goat_cleaned.[bim/bed/fam]
      - **cattle**: PLINK_QC_PABLO_TUTTO.[bim/bed/fam] $\rightarrow$ cattle_cleaned.[bim/bed/fam] 
      - **maize**: SNP55K_maize282.[bim/bed/fam]<sup>*</sup> $\rightarrow$ maize_cleaned.[bim/bed/fam]
      - **peach**: combined_18k.[bim/bed/fam] $\rightarrow$ peach_cleaned.[bim/bed/fam]
      - **simulated data**: simdata.[bim/bed/fam] [no cleaning, since this is simulated data: it directly went to the filtering step]
2. [split_pops.sh](imputation_support_scripts/split_pops.sh): script that takes in input the cleaned data by species and splits them into the corresponding subpopulations
      - **sheep**: sheep_cleaned.[bim/bed/fam] $\rightarrow$ [AustralianSuffolk|Rambouillet|Soay].[bim/bed/fam]
      - **goat**: goat_cleaned.[bim/bed/fam] $\rightarrow$ [ALP|BOE|LNR].[bim/bed/fam]
      - **cattle**: cattle_cleaned.[bim/bed/fam] $\rightarrow$ [ANG|HOL|LMS].[bim/bed/fam]
      - **maize**: maize_cleaned.[bim/bed/fam] $\rightarrow$ [nss|ts|mixed].[bim/bed/fam]
      - **peach**: peach_cleaned.[bim/bed/fam] $\rightarrow$ [CxEL|DxP|pop004].[bim/bed/fam]
      - **simulated data**: simdata.[bim/bed/fam] $\rightarrow$ [line1|line2|line3].[bim/bed/fam]
3. [filter_genotypes.sh](imputation_support_scripts/filter_genotypes.sh): takes in input the cleaned data and apply some filtering criteria on the SNP genotypes
      - \<dataset\>_cleaned.[bim/bed/fam] $\rightarrow$ \<dataset\>_filtered.[bim/bed/fam]
      - common set of parameters across datasets (loose filtering: min MAF = 0.01; min MAC = 4; max missing-rate per SNP = 0.05; max missing-rate per sample = 0.2)
      - applied to both the combined species datasets and the individual populations datasets (e.g. Rambouillet sheep, Soay sheep etc.)
4. [make_random_LD_array.py](imputation_support_scripts/make_random_LD_array.py): script to generate *n* LD SNP arrays by randomly sampling the original HD/MD SNP array
      - 7000 SNPs were randomly sampled for the LD SNP array in cattle, goat, sheep and maize; 1500 SNPs were sampled for the simulated data; 1000 SNPs were sampled for the peach LD array

### Imputation

1. [run_gapimputation.sh](run_gapimputation.sh):
      - first, edit the [config file](https://github.com/filippob/heterogeneousImputation/config.sh): prefix for the type of analysis (e.g. GAPIMPUTATION), paths to software (Rscript, Plink, Beagle)
      - edit also the [pathNames.txt](https://github.com/filippob/heterogeneousImputation/pathNames.txt) file: path to the project folder (where the analysis is run), more paths to software
      - run as: `bash run_gapimputation.sh $datafolder/$dataset $missrate $sample_size $species` $\rightarrow$ e.g. `bash run_gapimputation.sh filtered_data/cattle_filtered 0.01 20 cow`

---

<sup>*</sup><sub>the binary Plink fileset `SNP55K_maize282` was obtained from the raw data files (single hapmap files for each chromosome) using custom scripts (1.hapmap2vcf.sh; 2.merge_vcf.sh; 4.vcf2plink.sh)</sub>
