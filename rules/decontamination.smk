rule decontamination:
    input:
        fa = "results/purge_haplotigs/{sample}_purged.fa",
    output:
        dec_fa = "results/decontamination/{sample}_dec.fa",
        report = "results/decontamination/{sample}_kraken2.report",
        classification = "results/decontamination/{sample}_kraken2.output",
    params:
        outdir = "results/decontamination",
        extra = config["kraken2"]["extra_args"],
        confidence = config["kraken2"]["confidence"],
        db = config["kraken2"]["db"],
    threads: config["threads"]["kraken2"]
    conda: "envs/decontamination.yaml"
    log: "logs/decontamination/{sample}_decontamination.log"
    benchmark: "benchmarks/kraken2/{sample}.txt"
    shell:
        """
        kraken2 \
            --db {params.db} \
            --threads {threads} \
            --confidence {params.confidence} \
            --output {output.classification} \
            --report {output.report} \
            --unclassified-out {output.dec_fa} \
            {params.extra} \
            {input.fa} \
            > {log} 2>&1
        """