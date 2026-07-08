# Setup Guide & Usage

## System requirements
The workflow works mainly on **Linux x86-64 HPC** systems. It's currently being tested on a macOS system with M4 ARM CPU.

The total resources needed are based on the size of the data and the genome that is been analyzed.

**Recomended specs**

- GNU Linux 64 bit
- x86-64 CPU Architecture, Min: 32 Cores
- A lot of RAM, Min: 120GB
- Slurm Workload Manager 

Some recomended options on threads:
(These are the default settings in `config.yaml` based on the _Stenella coeruleoalba_)

| Tool | Threads |
|------|---------|
| samtools | 16 |
| porechop | 16 |
| flye | 32 |
| hifiasm | 32 |
| medaka | 8 |
| purge_haplotigs | 16 |
| kraken2 | 16 |
| nanostat | 8 |
| quast | 8 |
| busco | 16 |
| multiqc | 8 |

### Depedencies
- **Flye**
- **Hifiasm**
- **Porechop**
- **Medaka**
- **Purge_haplotigs**
- **Nanostat**
- **QUAST**
- **BUSCO**
- **multiQC**
- **Kraken 2**
- **Seqkit**
- **Samtools**
- **NCBI Datasets** (_Optional_)


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
git clone https://github.com/mikeph52/nessie.git
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
|              Nessie               |
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
### Workflow configuration
All settings and configuration is managed from the [config.yaml](config/config.yaml), found in the `config/` folder. Inside the config file there are 5 sections:

- **Samples**
Load your .BAM files here.

```yaml
samples: #.BAM files
  - sample1
  - sample2
  # etc
```
- **Assembler**

Select the assembler to use on the assembly between **Flye** for Nanopore reads and **Hifiasm** for PacBio HiFi reads.
```yaml
assembler: flye #flye or hifiasm
```

- **Genome size**

Enter the genome size of the organism. It's required for **Flye** and **QUAST** to run.
```yaml
genome_size: "500m"
```

- **Threads**

Select the threads for each tool, depending on the available resources and the 

```yaml
threads:
  samtools: 16
  porechop: 16
  flye: 32
# . . . 
```

- **Tools arguments**
Here you can add additional arguments for the tools in this workflow.

```yaml
flye:
  read_type: "--nano-hq"    # --nano-raw # --nano-hq # --pacbio-raw # --pacbio-hifi
  extra_args: ""

busco:
  lineage: "fungi_odb10" # example for S.cerevisiae
  mode: "genome"
  extra_args: ""
# . . . 
```

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