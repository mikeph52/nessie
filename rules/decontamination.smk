rule decontamination:
    input:
        fa = "results/purge_dups/{sample}_purged.fa",
        db = "data/kraken2-db/", #not created, just default dir
    output:
        dec_fa = "results/decontamination/{sample}_dec.fa"
        report = "results/decontamination/kraken2.report"
    params:
        outdir = "results/decontamination",
        extra = config["kraken2"]["extra_args"],
        confidence = config["kraken2"]["confidence"],
    threads: config["threads"]["kraken2"]
    conda: "envs/decontamination.yaml"
    log: "logs/{sample}_decontamination.log"
    shell:
        """
        mkdir data/kraken2-db
        kraken2-build --standard --db kraken2-db

        kraken2 \
            --db {input.db} \
            --threads {threads} \
            --confidence {params.confidence}\
            --output {params.outdir}/kraken2.output \
            --report {params.outdir}/kraken2.report \
            --fasta-input {input.fa}
            --unclassified-out {output.dec_fa}
        """