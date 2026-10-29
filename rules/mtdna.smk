rule mtdna_detection:
    input:
        fasta  = "results/assembly/flye/{sample}_assembly.fasta",
    output:
        mt_dna = "results/mtdna/{sample}_mtdna.fasta"
    threads: config["threads"]["mitohifi"] # change when completed
    conda: "envs/mtdna.yaml"
    log: "logs/mtdna/{sample}.log"
    benchmark: "benchmarks/mtdna/{sample}.txt"
    shell:
        """
        mkdir -p logs/mtdna/
        mkdir -p results/mtdna/{wildcards.sample}
        echo "$(date): mtDNA detection is starting (rules/mtdna.smk)..."
        echo "$(date): Pulling mitohifi singularity container..."

        singularity exec \
         --bind /path/to/container_directory:/path/to/container_directory \
         docker://ghcr.io/marcelauliano/mitohifi:master \
         mitohifi.py -h

        echo "$(date): Pulling mitohifi singularity container completed."
        echo "$(date): Fetch reference mtDNA..."

        singularity exec -B $PWD $MITOHIFI $FINDMITO \
            --species "Stenella coeruleoalba" \
            --email mikeph526@outlook.com \
            --outfolder ref \
            --min_length 14000
        
        echo "$(date): Reference mtDNA successfully fetched."
        echo "$(date): mitoHiFi is starting..."

        singularity exec --cleanenv "$MITOHIFI" bash -c "
            export PATH=\$PATH:/opt/wrappers:/opt/MitoHiFi/src:/opt/cdhit
            $MITOSRC/mitohifi.py \
                -c $ASM \
                -f $REFDIR/$ACC.fasta \
                -g $REFDIR/$ACC.gb \
                -t $THREADS \
                -o 2 \
                -a animal
        "
        echo "$(date): mitoHiFi completed."
        echo "$(date): mtDNA detection completed."
        """

    # check mtdna.yaml for more info regarding the mitohifi running method