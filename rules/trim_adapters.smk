rule sort_bam:
    input:
        bam = "data/{sample}.bam"
    output:
        sorted_bam = temp("results/sort_bam/{sample}_sorted.bam"),
        fastq = "results/sort_bam/{sample}.fastq.gz"
    log:
        "logs/sort_bam/{sample}.log"
    threads: config["threads"]["samtools"]
    conda: "envs/trim_adapters.yaml"
    benchmark: "benchmarks/sort_bam/{sample}.txt"
    shell:
        """
        echo "$(date): Trimming adapters is starting (rules/trim_adapters.smk)..."
        echo "$(date): Samtools is starting..."
        echo "SORTING STARTED" >> {log}
        samtools sort -n -@ {threads} -m 2G -o {output.sorted_bam} {input.bam} 2>> {log}
        echo "SORTING ENDED, CONVERSION STARTED" >> {log}

        samtools fastq -@ {threads} {output.sorted_bam} | bgzip -@ {threads} > {output.fastq} 2>> {log}
        echo "CONVERSION ENDED" >> {log}
        echo "$(date): Samtools completed"
        """

rule filter_dcs:
    input:
        fastq = raw_fastq, # detected data file from snakefile
    output:
        filtered = "results/trim_adapters/{sample}_filtered.fastq.gz",
    params:
        dcs_ref = config.get("dcs_ref", "data/dcs_reference.fasta"),
    threads: config["threads"]["samtools"]
    conda:  "envs/trim_adapters.yaml"
    log:       "logs/trim_adapters/{sample}_filter_dcs.log"
    benchmark: "benchmarks/filter_dcs/{sample}.txt"
    shell:
        """
        echo "$(date): Filtering DCS is starting..."
        minimap2 -t {threads} -ax map-ont \
            {params.dcs_ref} {input.fastq} \
            2>> {log} \
            | samtools view -f 4 -b 2>> {log} \
            | samtools fastq 2>> {log} \
            | pigz -p {threads} > {output.filtered}
        echo "$(date): Filtering DCS finished."
        """