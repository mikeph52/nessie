rule medaka:
    input:
        fastq = "results/trim_adapters/{sample}_trimmed.fastq.gz",
        fasta  = "results/assembly/flye/{sample}/{sample}_assembly.fasta",
    output:
        fasta  = "results/polish/medaka/{sample}_polished.fasta", # fix later
    params:
        outdir = "results/polish/medaka",
        model  = config["medaka"]["model"],
        extra  = config["medaka"]["extra_args"],
    threads: config["threads"]["medaka"]
    conda:  "envs/polish.yaml"
    log:    "logs/medaka/{sample}.log"
    shell:
        """
        medaka_consensus \
            -i {input.fastq} \
            -d {input.fasta} \
            -o {params.outdir} \
            -t {threads} \
            -m {params.model} \
            {params.extra} \
            2> {log}

        mv {params.outdir}/consensus.fasta {params.outdir}/{sample}_polished.fasta
        """