#!/bin/bash

#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem=40000              
#SBATCH --job-name="smk_assembly"
#SBATCH --output=logs/assembly.output
#SBATCH --mail-user=
#SBATCH --mail-type=ALL

THREADS=32

set -euo pipefail

source ~/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

snakemake --cores "$THREADS" --use-conda --dry-run