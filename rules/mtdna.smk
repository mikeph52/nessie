rule mtdna_detection:
    input:
        fasta  = "results/assembly/flye/{sample}_assembly.fasta",
    output:
    threads: config["threads"]["mitohifi"] # change when completed
    conda: "envs/mtdna.yaml"
    log: "logs/mtdna/{sample}.log"
    benchmark: "benchmarks/mtdna/{sample}.txt"
    shell:
        """
        mkdir -p logs/mtdna/
        mkdir -p results/mtdna/{wildcards.sample}
        echo "$(date): mtDNA detection is starting (rules/mtdna.smk)..."
        echo "$(date): mitoHiFi is starting..."

        # check if singularity exists
        which singularity
        export $PATH=

        singularity mitohifi

        """

    # check mtdna.yaml for more info regarding the mitohifi running method