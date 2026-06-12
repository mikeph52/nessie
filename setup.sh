#!/bin/bash

set -euo pipefail

echo "-------------------------------------"
echo "|              Nessie               |"
echo "|De novo assembly snakemake workflow|"
echo "|         by mikeph52, 2026         |"
echo "-------------------------------------"

read -p "Enter project name: " PROJECT

if [[ -z "$PROJECT" ]]; then
    echo "Project name cannot be empty."
    exit 1
fi
# save project name to scripts/
echo "$PROJECT" > scripts/.setup.env

echo "The following changes will happen:"
echo " - Name project $PROJECT"
echo " - Create directories: data/ logs/ results/"
echo " - Create subfolders on: data/ results/"
echo " - Check conda availability"
echo " - Install snakemake if it is not installed"
echo " - Create 'snakemake_assembly' conda venv"
echo " - Remove docs/"
echo " - Move setup.sh to scripts/"

read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# STEP 1
echo "Naming project '$PROJECT'..."
cd ..
mv nessie "$PROJECT"
cd "$PROJECT"
# STEP 2
echo "Creating directories: data/ logs/ results/ benchmarks/..."
mkdir data logs results
# STEP 3
echo "Creating subdfolders on: data/ results/..."
mkdir -p data/
mkdir -p results/sort_bam results/trim_adapters results/assembly results/purge_haplotigs results/polish 
mkdir -p results/assembly/flye/ results/assembly/hifiasm/
mkdir -p benchmarks/
# STEP 4
echo "Checking conda installation..."
if ! command -v conda &> /dev/null; then
    echo "Error: conda is not installed. Please install conda and re-run the setup.sh script"
    echo "For more information visit this link:https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html" 
    rm -rf data logs results
    cd ..
    mv "$PROJECT" nessie
    exit 1
fi
echo "conda found: $(conda --version)"
# STEP 5
echo "Installing snakemake..."
conda create -n snakemake_assembly -c conda-forge -c bioconda snakemake mamba -y
# STEP 6
echo "Remove docs/..."
rm -rf docs/
# STEP 7
echo "Moving setup.sh to scripts/..."
mv setup.sh scripts/
echo "Cd out of the folder and enter again to refresh the project title."

echo "Process finished"