rule plots:
    input:
        quast   = expand("results/qc/quast/{sample}/report.tsv", sample=SAMPLES),
        busco   = expand("results/qc/busco/{sample}/short_summary.specific.{lineage}.{sample}.txt",
                         sample=SAMPLES, lineage=config["busco"]["lineage"]),
        nanostat = expand("results/qc/nanostat/{sample}_raw/NanoStats.txt", sample=SAMPLES),
    output:
        plot = "results/qc/assembly_stats.png",
    log:    "logs/qc/plot_stats.log"
    conda:  "envs/plots.yaml"
    script: "scripts/plots.py"