#!/bin/bash

#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem=40000              
#SBATCH --job-name="download_kraken2db"
#SBATCH --output=logs/download_kraken2db.output

echo "$(date): Kraken2 standard database download."
echo "$(date): Creating data/kraken2_db."
mkdir -p data/kraken2_db

echo "$(date): Fetching kraken2 standard db."
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20240904.tar.gz

echo "$(date): Extracting db to data/kraken2_db."
tar -xvf k2_standard_08gb_20240904.tar.gz -C data/kraken2_db

echo "$(date): Cleaning up."
rm -rf k2_standard_08gb_20240904.tar.gz

echo "$(date): Process completed."