rule purge_haplotigs:
    input:
        fasta = f"results/assembly/{ASSEMBLER}/{{sample}}_assembly.fasta",
        fastq = "results/trim_adapters/{sample}_trimmed.fastq.gz",
    output:
        fa  = "results/purge_haplotigs/{sample}_purged.fa",
        hap = "results/purge_haplotigs/{sample}_hap.fa",
    params:
        outdir = "results/purge_haplotigs/{sample}",
        extra = config["purge_haplotigs"].get("extra_args", ""),
    threads: config["threads"]["purge_haplotigs"]
    conda:  "envs/rm_haplotigs.yaml"
    log:    "logs/purge_haplotigs/{sample}.log"
    shell:
        """
        echo "$(date): Remove haplotigs is starting (rules/rm_haplotigs.smk)..."
        echo "$(date): Purge_haplotigs is starting..."
        mkdir -p {params.outdir}

        echo "$(date): Aligning reads to assembly..."
        minimap2 -t {threads} -ax map-ont \
            {input.fasta} {input.fastq} \
            | samtools sort -@ {threads} -o {params.outdir}/aligned.bam 2>> {log}

        samtools index {params.outdir}/aligned.bam 2>> {log}

        echo "$(date): Generating coverage histogram..."
        
        purge_haplotigs hist -b {params.outdir}/aligned.bam -g {input.fasta} -t {threads} 2>> {log}

        mv aligned.bam.gencov {params.outdir}/aligned.bam.gencov
        
        echo "$(date): Computing cutoffs from histogram..."

        minimap2 -t {threads} -xmap-ont {input.fasta} {input.fastq} | pigz -p {threads} > {params.outdir}/reads.paf.gz 2>> {log}
        pbcstat {params.outdir}/reads.paf.gz -O {params.outdir} 2>> {log}
        calcuts {params.outdir}/PB.stat > {params.outdir}/cutoffs 2>> {log}

        LOW=$(awk  'NR==1{{print $1}}' {params.outdir}/cutoffs)
        MID=$(awk  'NR==1{{print $3}}' {params.outdir}/cutoffs)
        HIGH=$(awk 'NR==1{{print $5}}' {params.outdir}/cutoffs)

        echo "$(date): Cutoffs — low=$LOW mid=$MID high=$HIGH" 2>> {log}

        echo "$(date): Setting coverage cutoffs..."
        purge_haplotigs cov \
            -i {params.outdir}/aligned.bam.gencov \
            -l $LOW -m $MID -h $HIGH \
            -o {params.outdir}/coverage_stats.csv 2>> {log}

        echo "$(date): Purging haplotigs..."
        purge_haplotigs purge \
            -g {input.fasta} \
            -c {params.outdir}/coverage_stats.csv \
            -t {threads} \
            -o {params.outdir}/{wildcards.sample}_purged \
            2>> {log}

        mv {params.outdir}/{wildcards.sample}_purged.fasta {output.fa}
        mv {params.outdir}/{wildcards.sample}_purged.haplotigs.fasta {output.hap}

        echo "$(date): Purge_haplotigs completed"
        echo "$(date): Remove haplotigs completed"
        """