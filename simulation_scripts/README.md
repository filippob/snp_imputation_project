## Workflow for genomic data simulation

1. `1.simulate_genotypes.sh`: script based on the [QMSim software](https://animalbiosciences.uoguelph.ca/~msargol/qmsim/) that sìmulates SNP genotype data, based on the [parameter file](paramfiles/sim1.prm)
    - `1.2.preprocess_simdata.sh`: this script updates SNP positions from floats to integers (correct format for next steps with Plink/Vcftools)
3. `2.create_ped_map.sh`
4. `3.convert_allele_coding.sh`
