#!/bin/bash

#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem=40000              
#SBATCH --job-name="download_kraken2db"
#SBATCH --output=logs/download_kraken2db.output

mkdir -p data/kraken2_db
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20240904.tar.gz
tar -xvf k2_standard_08gb_20240904.tar.gz -C data/kraken2_db