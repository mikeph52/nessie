# De novo genome assembly workflow for mammalian species using long reads workflow

## Introduction
This workflow supports sequecing data from both Oxford Nanopore and Pacbio HiFi sequencers, built with snakemake for maximum compatibility.
The pipeline is based on the one used in _De Novo Genome Assembly for an Endangered Lemur Using Portable Nanopore Sequencing in Rural Madagascar_(Hauff et. all, 2025).

## Workflow
### Pipeline structure

![](docs/snakemake_workflow_2.png)

### Project structure
```bash
.
├── config.yaml
├── data
├── docs
│   └── snakemake_workflow.png
├── envs
│   ├── annotation.yaml
│   ├── assembly.yaml
│   ├── decontamination.yaml
│   ├── masking.yaml
│   ├── polish.yaml
│   ├── qc.yaml
│   ├── rm_haplotigs.yaml
│   └── trim_adapters.yaml
├── LICENSE
├── logs
├── README.md
├── results
├── rules
│   ├── assembly.smk
│   ├── custom_k2_db.smk
│   ├── decontamination.smk
│   ├── masking.smk
│   ├── polish.smk
│   ├── qc.smk
│   ├── rm_haplotigs.smk
│   └── trim_adapters.smk
├── scripts
│   └── reset.sh
├── setup.sh
├── snakefile
└── workflow.sh
```	
### System requirements
The workflow works mainly on **Linux x86-64 HPC** systems. It's currently being tested on a macOS system with M4 ARM CPU.

The total resources needed are based on the size of the data and the genome that is been analyzed.

**Recomended specs**

- GNU Linux 64 bit
- x86-64 CPU Architecture, Min: 32 Cores
- A lot of RAM, Min: 120GB
- Slurm Workload Manager 

Some recomended options on threads:
(These are the default settings in `config.yaml`)

| Tool | Threads |
|------|---------|
| samtools | 16 |
| porechop | 16 |
| flye | 32 |
| hifiasm | 32 |
| medaka | 8 |
| purge_dups | 16 |
| kraken2 | 16 |
| repeatmasker | 16 |
| nanostat | 8 |
| quast | 8 |
| busco | 16 |
| multiqc | 8 |

### Depedencies
- **Flye**
- **Hifiasm**
- **Porechop**
- **Medaka**
- **Purge_dups**
- **RepeatMasker**
- **QUAST**
- **BUSCO**
- **Kraken 2**
- **Seqkit**
- **NCBI Datasets** (_Optional_)
- **BlobToolkit** (_Optional_)

## Installation
### 1. Conda
In order to run the workflow, conda must be installed. Bellow are the full steps for installing and setup conda and bioconda for Linux machines. If you want to experiment with other configurations and distros, [here are the instructions](https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html#regular-installation).

_Taken from the official conda documentation._

**Download the installer**:
- Miniconda installer for Linux --> [link](https://docs.anaconda.com/miniconda/)
- Anaconda Distribution installer for Linux --> [link](https://www.anaconda.com/download/)
- Miniforge installer for Linux --> [link](https://conda-forge.org/download/)

**Verify your installer hashes** --> [link](https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html#hash-verification)

**Run this command**:
```bash
bash <conda-installer-name>-latest-Linux-x86_64.sh
```
`conda-installer-name` will be one of "Miniconda3", "Anaconda", or "Miniforge3".

Then follow instructions on screen.

**Verify installation with**:
```bash
conda list
```
**Setup Bioconda**:

To add the bioconda channel on `~/.condarc` file, run the following in the correct order:
```bash
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict
```

Even if you have a previous bioconda setup, it is recommended to re-run these commands.
### 2. Setup workflow

**Download the repository**:
You can simply `git clone` the repo, or download it manually from GitHub or the new GitHub CLI app.
```bash
git clone https://github.com/mikeph52/de_novo_assembly_workflow.git
```
**Run setup.sh from inside the folder**:
```bash
./setup.sh
# or
bash setup.sh
```
Follow instructions. The `setup.sh` script enables you to rename the folder to your liking, creates importand project folders, checks for an existent conda installation and installs snakemake if it's not installed.

Here's an example of the script:
```
-------------------------------------
|De novo assembly snakemake workflow|
|         by mikeph52, 2026         |
-------------------------------------
Enter project name: pseudomonas_syringae
The following changes will happen:
 - Name project pseudomonas_syringae
 - Create directories: data/ logs/ results/
 - Create subfolders on: data/ results/
 - Check conda availability
 - Install snakemake if it is not installed
 - Move setup.sh to scripts/
Continue? (Y/N): 
```
### 3. Reset installation
If you want to revert changes made by the `setup.sh` script, run the `reset.sh` inside the `scripts/` folder.

## Usage
### Execution with Slurm
To execute the workflow in an HPC System with the Slurm workflow manager installed, execute the `workflow.sh` script.
```bash
sbatch workflow.sh
```
### Manual execution
Inside the project folder, run the following:
```bash
snakemake -j 20 # select the cores you need
```

### Under Construction :-(





## Acknowledgements

All data used for the development of this workflow were provided by the
**Institute of Marine Biology, Biotechnology and Aquaculture (IMBBC)**
of the **Hellenic Centre for Marine Research (HCMR)**, Heraklion, Crete.
This workflow was developed and executed on the **Zorbas HPC** infrastructure of IMBBC-HCMR.

## References
- Hauff, L., Rasoanaivo, N.E., Razafindrakoto, A., Ravelonjanahary, H., Wright, P.C., Rakotoarivony, R. and Bergey, C.M. (2025), De Novo Genome Assembly for an Endangered Lemur Using Portable Nanopore Sequencing in Rural Madagascar. Ecol Evol, 15: e70734. [https://doi.org/10.1002/ece3.70734](https://doi.org/10.1002/ece3.70734)
- Bekavac M, Coimbra R, Busa VF, et al. De novo genome assembly of Ansell's mole-rat (Fukomys anselli). G3 (Bethesda). 2026;16(1):jkaf271. doi:10.1093/g3journal/jkaf271
- Kolmogorov, M., Yuan, J., Lin, Y. et al. Assembly of long, error-prone reads using repeat graphs. Nat Biotechnol 37, 540–546 (2019). https://doi.org/10.1038/s41587-019-0072-8
