rule medaka:
    input:
        fastq = "results/trim_adapters/{sample}_trimmed.fastq.gz",
        fasta  = f"results/assembly/{ASSEMBLER}/{{sample}}_assembly.fasta",
    output:
        fasta  = "results/polish/medaka/{sample}_polished.fasta", # fix later
    params:
        outdir = "results/polish/medaka/{sample}",
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

        mv {params.outdir}/consensus.fasta {output.fasta}
        """