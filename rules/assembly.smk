rule flye_assembly:
    input:
        fastq = "results/trim_adapters/{sample}_trimmed.fastq.gz"
    output:
        fasta  = "results/assembly/flye/{sample}_assembly.fasta",
        info   = "results/assembly/flye/{sample}_assembly_info.txt",
        graph  = "results/assembly/flye/{sample}_assembly_graph.gfa",
    params:
        outdir = "results/assembly/flye/{sample}", 
        read_type = config["flye"]["read_type"],
        genome_sz = config["genome_size"],
        extra     = config["flye"]["extra_args"],
    threads: config["threads"]["flye"]
    conda: "envs/assembly.yaml"
    log: "logs/flye/{sample}.log"
    shell:
        """
        mkdir -p logs/flye/
        mkdir -p results/assembly/flye/{sample}
        echo "$(date): Assembly is starting (rules/assembly.smk)..."
        echo "$(date): Flye is starting..."

        flye \
            {params.read_type} {input.fastq} \
            --genome-size {params.genome_sz} \
            --out-dir {params.outdir} \
            --threads {threads} \
            {params.extra} \
            2> {log}

        echo "$(date): Flye completed."
        echo "$(date): Assembly completed."
        """

rule hifiasm_assembly:
    input:
        fastq = "results/trim_adapters/{sample}_trimmed.fastq.gz"
    output:
        fasta  = "results/assembly/hifiasm/{sample}_assembly.fasta",
    params:
        outdir = "results/assembly/hifiasm/{sample}",
        asm_ext = "{sample}.asm",
        extra = config["hifiasm"]["extra_args"],
    threads: config["threads"]["hifiasm"]
    conda:  "envs/assembly.yaml"
    log:    "logs/hifiasm/{sample}.log"
    shell:
        """
        mkdir -p logs/hifiasm/
        mkdir -p results/assembly/hifiasm/{sample}
        echo "$(date): Assembly is starting (rules/assembly.smk)..."
        echo "$(date): Hifiasm is starting..."

        hifiasm \
            -o {params.outdir}/{params.asm_ext} \
            -t {threads} \
            {params.extra} \
            {input.fastq} \
            2> {log}

        echo "$(date): Hifiasm completed."
        echo "$(date): Converting gfa to FASTA..."
        # convert .gfa to fasta
        awk '/^S/{print ">"$2"\n"$3}' results/assembly/hifiasm/{sample}.bp.p_ctg.gfa > results/assembly/hifiasm/{sample}_assembly.fasta

        echo "$(date): Conversion completed."
        echo "$(date): Assembly completed."
        """

