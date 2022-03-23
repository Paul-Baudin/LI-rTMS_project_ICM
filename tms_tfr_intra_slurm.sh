#!/bin/bash
#SBATCH --job-name=tms_tfr
#SBATCH --partition=normal,bigmem
#SBATCH --time=99:99:99
#SBATCH --mem=120G
#SBATCH --cpus-per-task=2
#SBATCH --chdir=.
#SBATCH --output=/network/lustre/iss01/charpier/analyses/tms/output_slurm/%j_%a-%x_output.txt
#SBATCH --error=/network/lustre/iss01/charpier/analyses/tms/output_slurm/%j_%a-%x_error.txt
#SBATCH --array=7-25

module load MATLAB/R2019b
matlab -nodesktop -softwareopengl -nosplash -nodisplay -r "tms_tfr_intra($SLURM_ARRAY_TASK_ID);"
sleep 5;
