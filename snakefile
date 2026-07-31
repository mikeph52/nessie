from datetime import datetime
import os
import glob

# This is the config file
configfile: "config/config.yaml"

W_VERSION = "0.22.1"
SAMPLES  = config["samples"]
ASSEMBLER = config["assembler"]

# def to autodetect input file type
def detect_file_type(sample):
    if os.path.exists(f"data/{sample}.fastq.gz"):
        return "fastq"
    elif os.path.exists(f"data/{sample}.bam"):
        return "bam"
    else:
        raise ValueError(
            f"No input file found for sample '{sample}'. "
            f"Expected data/{sample}.fastq.gz or data/{sample}.bam"
        )

INPUT_TYPES = {sample: detect_file_type(sample) for sample in SAMPLES}

def raw_fastq(wildcards):
    if INPUT_TYPES[wildcards.sample] == "fastq":
        return f"data/{wildcards.sample}.fastq.gz"
    else:
        return f"results/sort_bam/{wildcards.sample}.fastq.gz"
# rules
include: "rules/trim_adapters.smk" # This is may obsolete
include: "rules/assembly.smk"
include: "rules/polish.smk"        # ONT only — comment out for HiFi
include: "rules/rm_haplotigs.smk"
#include: "rules/custom_k2_db.smk" # uncomment to build a custom Kraken2 db
include: "rules/decontamination.smk"
include: "rules/qc.smk"
include: "rules/plots.smk"

BANNER = r"""
        .-') _   ('-.    .-')     .-')               ('-.   
    ( OO ) )_(  OO)  ( OO ).  ( OO ).           _(  OO)  
,--./ ,--,'(,------.(_)---\_)(_)---\_)  ,-.-') (,------. 
|   \ |  |\ |  .---'/    _ | /    _ |   |  |OO) |  .---' 
|    \|  | )|  |    \  :` `. \  :` `.   |  |  \ |  |     
|  .     |/(|  '--.  '..`''.) '..`''.)  |  |(_/(|  '--.  
|  |\    |  |  .--' .-._)   \.-._)   \ ,|  |_.' |  .--'  
|  | \   |  |  `---.\       /\       /(_|  |    |  `---. 
`--'  `--'  `------' `-----'  `-----'   `--'    `------' 
                                        by mikeph52 2026
"""

onstart:
    print(f"""
    {BANNER}
    Version: {W_VERSION}
    Date: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
    Samples: {SAMPLES}
    Assembler:{ASSEMBLER}
    Input: {INPUT_TYPES}
    """)

onsuccess:
    print(f""" Nessie v {W_VERSION} completed successfully {datetime.now().strftime("%Y-%m-%d %H:%M:%S")} """)
onerror:
    print(f""" Nessie v {W_VERSION} failed — check logs for details {datetime.now().strftime("%Y-%m-%d %H:%M:%S")} """)

rule all:
    input:
        # sort bam only if bam detected
        expand("results/sort_bam/{sample}.fastq.gz", sample=SAMPLES)
            if any(t == "bam" for t in INPUT_TYPES.values()) else [],
        expand("results/qc/nanostat/{sample}_raw/NanoStats.txt", sample=SAMPLES),
        expand("results/trim_adapters/{sample}_filtered.fastq.gz", sample=SAMPLES),
        expand("results/assembly/{assembler}/{sample}_assembly.fasta", assembler=ASSEMBLER, sample=SAMPLES),
        expand("results/polish/medaka/{sample}_polished.fasta", sample=SAMPLES),
        expand("results/purge_haplotigs/{sample}_purged.fa", sample=SAMPLES),
        expand("results/decontamination/{sample}_dec.fa", sample=SAMPLES),
        expand("results/qc/quast/{sample}/report.tsv", sample=SAMPLES),
        expand("results/qc/busco/{sample}/short_summary.specific.{lineage}.{sample}.txt", sample=SAMPLES, lineage=config["busco"]["lineage"]),
        expand("results/qc/multiqc/multiqc_report.html"),
        expand("results/qc/assembly_stats.png"),
