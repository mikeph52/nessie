from datetime import datetime
import os

# This is the config file
configfile: "config/config.yaml"

W_VERSION = "0.24.1"
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

# for polishing=True
def get_assembly_input(wildcards):
    if config.get("polish", True):
        return f"results/polish/medaka/{wildcards.sample}_polished.fasta"
    else:
        return f"results/assembly/{ASSEMBLER}/{wildcards.sample}_assembly.fasta"
# rules
include: "rules/checksum.smk" # for integrity check
include: "rules/trim_adapters.smk"
include: "rules/assembly.smk"
if config.get("polish", True): 
    include: "rules/polish.smk" 
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
    Polish: {config.get("polish", True)}
    """)

onsuccess:
    print(f""" Nessie v {W_VERSION} completed successfully {datetime.now().strftime("%Y-%m-%d %H:%M:%S")} """)
onerror:
    print(f""" Nessie v {W_VERSION} failed — check logs for details {datetime.now().strftime("%Y-%m-%d %H:%M:%S")} """)

rule all:
    input:
        # sort bam only if bam detected
        expand("results/checksums/{sample}_integrity.ok", sample=SAMPLES),
        expand("results/checksums/{sample}.sha256", sample=SAMPLES),
        expand("results/sort_bam/{sample}.fastq.gz", sample=SAMPLES)
            if any(t == "bam" for t in INPUT_TYPES.values()) else [],
        expand("results/qc/nanostat/{sample}_raw/NanoStats.txt", sample=SAMPLES),
        expand("results/trim_adapters/{sample}_filtered.fastq.gz", sample=SAMPLES),
        expand("results/assembly/{assembler}/{sample}_assembly.fasta", assembler=ASSEMBLER, sample=SAMPLES),
        *(expand("results/polish/medaka/{sample}_polished.fasta", sample=SAMPLES) # conditional polishing
            if config.get("polish", True) else[]),
        expand("results/purge_haplotigs/{sample}_purged.fa", sample=SAMPLES),
        expand("results/decontamination/{sample}_dec.fa", sample=SAMPLES),
        expand("results/qc/quast/{sample}/report.tsv", sample=SAMPLES),
        expand("results/qc/busco/{sample}/short_summary.specific.{lineage}.{sample}.txt", sample=SAMPLES, lineage=config["busco"]["lineage"]),
        "results/qc/multiqc/multiqc_report.html",
        "results/qc/assembly_stats.png",
