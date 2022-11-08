#!/bin/bash
#SBATCH --job-name=density-imputation    		# Job name
#SBATCH --get-user-env
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --ntasks=1                    # Run on a single task
#SBATCH --cpus-per-task=1             # Declare 1 CPUs per task
#SBATCH --mem=16gb                     # Job memory request
#SBATCH --output=/home/biscarinif/imputation/log/densityimp_%j.log   # Standard output and error log

repofolder="$HOME/imputation"
start=`date +%s`
bash $repofolder/run_multi_imputation.sh
end=`date +%s`
runtime=$((end-start))

echo "execution time was $runtime"
echo "DONE!"
