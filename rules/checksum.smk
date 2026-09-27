rule check_integrity:
    input:
        fastq = lambda wildcards: (
            f"data/{wildcards.sample}.fastq.gz"
            if INPUT_TYPES[wildcards.sample] == "fastq"
            else f"data/{wildcards.sample}.bam"
        ),
    output:
        ok  = touch("results/checksums/{sample}_integrity.ok"),
        sha = "results/checksums/{sample}.sha256",
    log: "logs/checksums/{sample}.log"
    benchmark: "benchmarks/checksum/{sample}.txt"
    script: "scripts/checksum.py"