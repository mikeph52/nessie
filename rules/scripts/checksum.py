# this is a script for checking sha256 checksum 
# it depends on the checksum.smk rule
import hashlib
import subprocess

file = snakemake.input.fastq

# gzip integrity check
print(f"$(date): Checking gzip integrity of {file}...")
result = subprocess.run(["gzip", "-t", file], capture_output=True, text=True)

with open(snakemake.log[0], "w") as logf:
    