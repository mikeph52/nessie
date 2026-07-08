# Nessie: A de novo genome assembly workflow for animal species using long reads
[![Snakemake](https://img.shields.io/badge/snakemake-≥5.6.0-brightgreen.svg?style=flat)](https://snakemake.readthedocs.io)

## Introduction
This workflow supports sequecing data from both Oxford Nanopore and Pacbio HiFi sequencers, built with snakemake for maximum compatibility.
The pipeline is based on the one used in _De Novo Genome Assembly for an Endangered Lemur Using Portable Nanopore Sequencing in Rural Madagascar_(Hauff et. all, 2025).

## Workflow
### Pipeline structure

![](docs/snakemake_workflow_3.png)

### Project structure
```bash
.
├── config
│   └── config.yaml
├── data
├── docs
├── benchmarks
├── kraken2_db.sh
├── LICENSE
├── logs
├── README.md
├── results
├── rules
│   ├── assembly.smk
│   ├── custom_k2_db.smk
│   ├── decontamination.smk
│   ├── envs
│   │   ├── assembly.yaml
│   │   ├── decontamination.yaml
│   │   ├── polish.yaml
│   │   ├── qc.yaml
│   │   ├── rm_haplotigs.yaml
│   │   └── trim_adapters.yaml
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
## Quick start guide

### 1. Install conda

In order to run the workflow, conda must be installed. You can download conda from the [official site](https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html#regular-installation).

_For more information, visit [Setup & usage guide](https://github.com/mikeph52/nessie/blob/main/docs/guide.md#1-conda)_

### 2. Clone workflow

Clone the repository or download from [releases](https://github.com/mikeph52/nessie/releases).

```bash
git clone https://github.com/mikeph52/nessie.git
```
### 3. Run setup.sh 

Run `setup.sh` and follow instructions.

```bash
./setup.sh
# or
bash setup.sh
```

### 4. Configure workflow

Configure workflow settings in `config.yaml`:

**Workflow parameters:**

| Parameter | Value |
|---|---|
| assembler | flye or hifiasm |
| genome_size | 500000000 (use exact number) |
| threads.samtools | 16 |
| flye.read_type | --nano-hq |
| busco.lineage | fungi_odb10 (example for S. cerevisiae) |
| busco.mode | genome |
| medaka.model | r1041_e82_400bps_sup_v5.2.0 |
| kraken2.db | data/kraken2_db |

### 5. Run workflow

Run workflow directly with snakemake or with the Slurm workflow manager, in a HPC System setting, _see more [here](https://github.com/mikeph52/nessie/blob/main/docs/guide.md#execution-with-slurm)_:

```bash
# run directly
snakemake -j 20
# run with SLURM
sbatch workflow.sh
```

_For more information, visit [Setup & usage guide](docs/guide.md)_

## Changelog
_Changelog starts from the first public version (v.0.18.1, 1/6/2026)_
### version 0.21.1 (25/6/2026)
- Fix java memory bug on BUSCO.
- Change default basecaller model.

### Version 0.20.2 (12/6/2026)
- Minor benchmarking bugs fixed in qc.smk.

### Version 0.20.1 (12/6/2026)
- Command `benchmark:` added to every `rule.smk` to capture resources.
- Banner logo added.
- Success and error warning message added.
- correct multiQC formatting issues.
- Minor bugs fixed.

### Version 0.19.1 (7/6/2026)
- Fix issue (https://github.com/mikeph52/nessie/issues/8)

### Version 0.18.1 (1/6/2026)
- Old rm_haplotigs.smk removed.
- Fixed automatic coverage cutoff computation.
- Formatting issues fixed.
- Fixed medaka version in conda env.

## Tests & Benchmarks
The workflow has been tested on 3 assemblies so far:
- **_Clonostachys chloroleuca_ strain Cc878**
- **_Eulemur rufifrons_**
- **_Alexandromys oeconomus_**

For the results of each test run, visit [benchmarks](docs/benchmarks.md).

## Acknowledgements

All data used for the development of this workflow were provided by the
**Institute of Marine Biology, Biotechnology and Aquaculture (IMBBC)**
of the **Hellenic Centre for Marine Research (HCMR)**, Heraklion, Crete.
This workflow was developed and executed on the **Zorbas HPC** infrastructure of IMBBC-HCMR (Zafeiropoulos et al., 2021).

## References

- Hauff, L., Rasoanaivo, N.E., Razafindrakoto, A., Ravelonjanahary, H., Wright, P.C., Rakotoarivony, R. and Bergey, C.M. (2025), De Novo Genome Assembly for an Endangered Lemur Using Portable Nanopore Sequencing in Rural Madagascar. Ecol Evol, 15: e70734. [https://doi.org/10.1002/ece3.70734](https://doi.org/10.1002/ece3.70734)

- Kolmogorov, M., Yuan, J., Lin, Y. et al. Assembly of long, error-prone reads using repeat graphs. Nat Biotechnol 37, 540–546 (2019). https://doi.org/10.1038/s41587-019-0072-8

- Cheng, H., Asri, M., Lucas, J., Koren, S., Li, H. (2024) Scalable telomere-to-telomere assembly for diploid and polyploid genomes with double graph. Nat Methods, 21:967-970. https://doi.org/10.1038/s41592-024-02269-8

- Tegenfeldt F., Kuznetsov D., Manni M., Berkeley M., Zdobnov E.M., Kriventseva E.V. OrthoDB and BUSCO update: annotation of orthologs with wider sampling of genomes.  Nucleic Acids Research, Volume 53, Issue D1, 6 January 2025, Pages D516–D522, https://doi.org/10.1093/nar/gkae987

- Alla Mikheenko, Vladislav Saveliev, Pascal Hirsch, Alexey Gurevich,
WebQUAST: online evaluation of genome assemblies,
Nucleic Acids Research (2023) 51 (W1): W601–W606. doi: 10.1093/nar/gkad406
First published online: May 17, 2023

- Wood, D.E., Lu, J. & Langmead, B. Improved metagenomic analysis with Kraken 2. Genome Biol 20, 257 (2019). https://doi.org/10.1186/s13059-019-1891-0

- Shen, Wei, BotondSipos, and LiuyangZhao. 2024. “SeqKit2: A Swiss Army Knife for Sequence and Alignment Processing.” iMeta3, e191. https://doi.org/10.1002/imt2.191

- Roach, M.J., Schmidt, S.A. & Borneman, A.R. Purge Haplotigs: allelic contig reassignment for third-gen diploid genome assemblies. BMC Bioinformatics 19, 460 (2018). https://doi.org/10.1186/s12859-018-2485-7

- Wick RR, Judd LM, Gorrie CL, Holt KE. Completing bacterial genome assemblies with multiplex MinION sequencing. Microb Genom. 2017;3(10):e000132. Published 2017 Sep 14. doi:10.1099/mgen.0.000132

- Danecek P, Bonfield JK, Liddle J, Marshall J, Ohan V, Pollard MO, Whitwham A, Keane T, McCarthy SA, Davies RM, Li H, Twelve years of SAMtools and BCFtools, GigaScience (2021) 10(2) giab008 [33590861]

- Philip Ewels, Måns Magnusson, Sverker Lundin, Max Käller, MultiQC: summarize analysis results for multiple tools and samples in a single report, Bioinformatics, Volume 32, Issue 19, October 2016, Pages 3047–3048, https://doi.org/10.1093/bioinformatics/btw354

- O’Leary NA, Cox E, Holmes JB, Anderson WR, Falk R, Hem V, Tsuchiya MTN, Schuler GD, Zhang X, Torcivia J, Ketter A, Breen L, Cothran J, Bajwa H, Tinne J, Meric PA, Hlavina W, Schneider VA. Exploring and retrieving sequence and metadata for species across the tree of life with NCBI Datasets. Sci Data. 2024 Jul 5;11(1):732. doi: 10.1038/s41597-024-03571-y. PMID: 38969627; PMCID: PMC11226681.

- Wouter De Coster, Svenn D’Hert, Darrin T Schultz, Marc Cruts, Christine Van Broeckhoven, NanoPack: visualizing and processing long-read sequencing data, Bioinformatics, Volume 34, Issue 15, August 2018, Pages 2666–2669, https://doi.org/10.1093/bioinformatics/bty149

- Haris Zafeiropoulos, Anastasia Gioti, Stelios Ninidakis, Antonis Potirakis, Savvas Paragkamian, Nelina Angelova, Aglaia Antoniou, Theodoros Danis, Eliza Kaitetzidou, Panagiotis Kasapidis, Jon Bent Kristoffersen, Vasileios Papadogiannis, Christina Pavloudi, Quoc Viet Ha, Jacques Lagnel, Nikos Pattakos, Giorgos Perantinos, Dimitris Sidirokastritis, Panagiotis Vavilis, Georgios Kotoulas, Tereza Manousaki, Elena Sarropoulou, Costas S Tsigenopoulos, Christos Arvanitidis, Antonios Magoulas, Evangelos Pafilis, 0s and 1s in marine molecular research: a regional HPC perspective, GigaScience, Volume 10, Issue 8, August 2021, giab053, https://doi.org/10.1093/gigascience/giab053
