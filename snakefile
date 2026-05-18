configfile: "config/config.yaml"

SAMPLES  = config["samples"]
ASSEMBLER = config["assembler"]

include: "rules/trim_adapters.smk"
include: "rules/assembly.smk"
include: "rules/polish.smk"        # ONT only — comment out for HiFi
include: "rules/rm_haplotigs.smk"
#include: "rules/custom_k2_db.smk" # uncomment to build a custom Kraken2 db
include: "rules/decontamination.smk"
#include: "rules/masking.smk"      # uncomment if needed
include: "rules/qc.smk"

rule all:
    input:
        expand("results/qc/nanostat/{sample}_raw/NanoStats.txt",     sample=SAMPLES),
        expand("results/qc/nanostat/{sample}_trimmed/NanoStats.txt", sample=SAMPLES),
        expand("results/trim_adapters/{sample}_trimmed.fastq.gz",    sample=SAMPLES),
        expand("results/assembly/{assembler}/{sample}_assembly.fasta", assembler=ASSEMBLER, sample=SAMPLES),
        expand("results/polish/medaka/{sample}_polished.fasta",      sample=SAMPLES),
        expand("results/purge_dups/{sample}_purged.fa",              sample=SAMPLES),
        expand("results/decontamination/{sample}_dec.fa",            sample=SAMPLES),
        #expand("results/masking/{sample}_masked.fa",                 sample=SAMPLES),
        #"results/qc/multiqc/multiqc_report.html",