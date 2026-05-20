rule purge_haplotigs:
    input:
        fasta = f"results/assembly/{ASSEMBLER}/{{sample}}_assembly.fasta",
        fastq = "results/trim_adapters/{sample}_trimmed.fastq.gz",
    output:
        fa  = "results/purge_dups/{sample}_purged.fa",
        hap = "results/purge_dups/{sample}_hap.fa",
    params:
        outdir    = "results/purge_dups/{sample}",
        read_type = config["purge_dups"].get("read_type", "-xmap-ont"),
        extra     = config["purge_dups"].get("extra_args", ""),
    threads: config["threads"]["purge_dups"]
    conda:  "envs/rm_haplotigs.yaml"
    log:    "logs/purge_dups/{sample}.log"
    shell:
        """
        echo "$(date): Remove haplotigs is starting (rules/rm_haplotigs.smk)..."
        echo "$(date): Purge_dups is starting..."
        mkdir -p {params.outdir}
        minimap2 -t {threads} {params.read_type} {input.fasta} {input.fastq} | pigz -p {threads} > {params.outdir}/reads.paf.gz 2>> {log}

        pbcstat {params.outdir}/reads.paf.gz -O {params.outdir} 2>> {log}
        calcuts {params.outdir}/PB.stat > {params.outdir}/cutoffs 2>> {log}

        minimap2 -t {threads} -xasm5 -DP {input.fasta} {input.fasta}| pigz -p {threads} > {params.outdir}/self.paf.gz 2>> {log}
        purge_dups \
            -T {params.outdir}/cutoffs \
            -c {params.outdir}/PB.base.cov \
            {params.outdir}/self.paf.gz > {params.outdir}/dups.bed 2>> {log}

        get_seqs -e {params.outdir}/dups.bed {input.fasta} \
            -p {params.outdir}/{wildcards.sample} 2>> {log}
        mv {params.outdir}/{wildcards.sample}.purged.fa {output.fa}
        mv {params.outdir}/{wildcards.sample}.hap.fa    {output.hap}
        echo "$(date): Purge_dups completed"
        echo "$(date): Remove haplotigs completed"
        """