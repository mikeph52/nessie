rule nanostat_raw:
    input:
        fastq = "results/sort_bam/{sample}.fastq.gz",
    output:
        stats = "results/qc/nanostat/{sample}_raw/NanoStats.txt",
    params:
        outdir = "results/qc/nanostat/{sample}_raw",
    threads: config["threads"]["nanostat"]
    conda: "envs/qc.yaml"
    log: "logs/qc/nanostat_raw/{sample}.log"
    benchmark: "benchmarks/nanostat_raw/{sample}.txt"
    shell:
        """
        NanoStat \
            --fastq {input.fastq} \
            --outdir {params.outdir} \
            --name NanoStats.txt \
            --threads {threads} \
            2> {log}
        """

rule nanostat_trimmed:
    input:
        fastq = "results/trim_adapters/{sample}_trimmed.fastq.gz",
    output:
        stats = "results/qc/nanostat/{sample}_trimmed/NanoStats.txt",
    params:
        outdir = "results/qc/nanostat/{sample}_trimmed",
    threads: config["threads"]["nanostat"]
    conda: "envs/qc.yaml"
    log: "logs/qc/nanostat_trimmed/{sample}.log"
    benchmark: "benchmarks/nanostat_trimmed/{sample}.txt"
    shell:
        """
        NanoStat \
            --fastq {input.fastq} \
            --outdir {params.outdir} \
            --name NanoStats.txt \
            --threads {threads} \
            2> {log}
        """

rule quast:
    input:
        fasta = "results/purge_haplotigs/{sample}_purged.fa",
    output:
        report = "results/qc/quast/{sample}/report.tsv",
    params:
        outdir    = "results/qc/quast/{sample}",
        genome_sz = config["genome_size"],
        reference = config["quast"].get("reference", ""),
        extra     = config["quast"].get("extra_args", ""),
    threads: config["threads"]["quast"]
    conda: "envs/qc.yaml"
    log: "logs/qc/quast/{sample}.log"
    benchmark: "benchmarks/quast/{sample}.txt"
    shell:
        """
        REF_ARG=""
        if [ -n "{params.reference}" ]; then
            REF_ARG="-r {params.reference}"
        fi

        quast.py \
            {input.fasta} \
            -o {params.outdir} \
            --threads {threads} \
            --est-ref-size {params.genome_sz} \
            $REF_ARG \
            {params.extra} \
            2> {log}
        """

rule busco:
    input:
        fasta = "results/purge_haplotigs/{sample}_purged.fa",
    output:
        summary = "results/qc/busco/{sample}/short_summary.specific.{lineage}.{sample}.txt",
    wildcard_constraints:
        lineage = config["busco"]["lineage"],
    params:
        outdir  = "results/qc/busco",
        lineage = config["busco"]["lineage"],
        mode    = config["busco"].get("mode", "genome"),
        extra   = config["busco"].get("extra_args", ""),
    threads: config["threads"]["busco"]
    conda: "envs/qc.yaml"
    log: "logs/qc/busco/{sample}.{lineage}.log"
    benchmark: "benchmarks/busco/{sample}.txt"
    shell:
        """
        busco \
            -i {input.fasta} \
            -o {wildcards.sample} \
            --out_path {params.outdir} \
            -l {params.lineage} \
            -m {params.mode} \
            -c {threads} \
            --force \
            {params.extra} \
            2> {log}
        """

rule multiqc:
    input:
        expand("results/qc/nanostat/{sample}_raw/NanoStats.txt",
               sample=SAMPLES),
        expand("results/qc/nanostat/{sample}_trimmed/NanoStats.txt",
               sample=SAMPLES),
        expand("results/qc/quast/{sample}/report.tsv",
               sample=SAMPLES),
        expand("results/qc/busco/{sample}/short_summary.specific.{lineage}.{sample}.txt",
               sample=SAMPLES, lineage=config["busco"]["lineage"]),
    output:
        report = "results/qc/multiqc/multiqc_report.html",
    params:
        outdir = "results/qc/multiqc",
        indir  = "results/qc",
    conda: "envs/qc.yaml"
    log: "logs/qc/multiqc.log"
    benchmark: "benchmarks/multiqc/{sample}.txt"
    shell:
        """
        multiqc \
            {params.indir} \
            -o {params.outdir} \
            --force \
            2> {log}
        """