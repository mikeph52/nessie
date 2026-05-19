#!/bin/bash

#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem=40000              
#SBATCH --job-name="smk_assembly"
#SBATCH --output=logs/assembly.output
#SBATCH --mail-user=
#SBATCH --mail-type=ALL

snakemake -j 20
