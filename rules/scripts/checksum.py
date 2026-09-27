# this is a script for checking sha256 checksum 
# it depends on the checksum.smk rule
import hashlib
import subprocess

file = snakemake.input.fastq

with open(snakemake.log[0], "w") as logf:
    # gzip integrity check
    logf.write(f"Checking gzip integrity of {file}...\n")
    result = subprocess.run(["gzip", "-t", file], capture_output=True, text=True)
    if result.returncode !=0:
        logf.write(f"CORRUPT: {file}\n{result.stderr}\n")
        raise ValueError(f"Corrupt or truncated file: {file} [NOT PASS]")
    logf.write(f"gzip [OK]: {file}\n")
    # sha256
    logf.write(f"Generating sha-256 for {file}...\n")
    sha256 = hashlib.sha256()
    with open(file, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            sha256.update(chunk)
    checksum = sha256.hexdigest()
    # write checksum file
    with open(snakemake.output.sha, "w") as cf:
        cf.write(f"{checksum}  {file}\n")
    logf.write(f"SHA-256: {checksum}  {file}\n")
    print(f"[OK] {file}\n  SHA-256: {checksum}")