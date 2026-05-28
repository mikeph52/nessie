rule decontamination:
    input:
        fa = "results/purge_haplotigs/{sample}_purged.fa",
    output:
        dec_fa = "results/decontamination/{sample}_dec.fa",
        report = "results/decontamination/{sample}_kraken2.report",
    params:
        outdir = "results/decontamination",
        extra = config["kraken2"]["extra_args"],
        confidence = config["kraken2"]["confidence"],
        db = config["kraken2"]["db"],
    threads: config["threads"]["kraken2"]
    conda: "envs/decontamination.yaml"
    log: "logs/decontamination/{sample}_decontamination.log"
    shell:
        """
        kraken2 \
            --db {params.db} \
            --threads {threads} \
            --confidence {params.confidence}\
            --output {output.dec_fa} \
            --report {output.report} \
            --fasta-input {input.fa} \
            --unclassified-out {output.dec_fa}
        """