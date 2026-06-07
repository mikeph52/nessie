rule purge_haplotigs:
    input:
        fasta = "results/polish/medaka/{sample}_polished.fasta",
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

        mv aligned.bam.*.gencov {params.outdir}/aligned.bam.gencov
        mv aligned.bam.*.png    {params.outdir}/ 2>/dev/null || true
        
        echo "$(date): Computing cutoffs from gencov..."

        LOW=5
        MID=$(awk '$3>0 && $3>max {{max=$3; peak=$2}} END{{print peak}}' \
            {params.outdir}/aligned.bam.gencov)
        HIGH=$(( MID * 2 ))
        echo "$(date): Cutoffs — low=$LOW mid=$MID high=$HIGH" | tee -a {log}

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
        # cleanup temp
        rm -rf tmp_purge_haplotigs/

        echo "$(date): Purge_haplotigs completed"
        echo "$(date): Remove haplotigs completed"
        """