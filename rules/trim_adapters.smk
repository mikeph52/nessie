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

rule porechop:
    input:
        fastq = "results/sort_bam/{sample}.fastq.gz"
    output:
        trimmed = "results/trim_adapters/{sample}_trimmed.fastq.gz"
    log:
        "logs/trim_adapters/{sample}.log"
    threads: config["threads"]["porechop"]
    conda: "envs/trim_adapters.yaml"
    benchmark: "benchmarks/porechop/{sample}.txt"
    shell:
        """
        echo "$(date): Porechop is starting..."
        porechop -i {input.fastq} -o {output.trimmed} --threads {threads} 2>> {log}
        echo "$(date): Porechop completed"
        echo "$(date): Trimming adapters completed."
        """