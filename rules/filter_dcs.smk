rule filter_dcs:
    input:
        fastq = "data/{sample}.fastq.gz",
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