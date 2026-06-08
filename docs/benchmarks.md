# Tests & Benchmarks
## Test run 1: _Clonostachys chloroleuca_ strain Cc878

### Data Information
| Field      | Value                    |
|------------|--------------------------|
| Bioproject | PRJNA1070537             |
| SRA        | SRR27765574              |
| Platform   | Oxford Nanopore          |
| Model      | PromethION               |
| Submitter  | Northwest A&F University |
| Date       | 2024-02-01               |

### Assembly statistics
| Metric                 | Value      |
|------------------------|------------|
| Source                 | GenBank    |
| Assembly name          |GCA_037952775.1|
| Genome size            | 59.4 Mb    |
| Total ungapped length  | 59.4 Mb    |
| Number of scaffolds    | 4          |
| Scaffold N50           | 37.5 Mb    |
| Scaffold L50           | 1          |
| Number of contigs      | 25         |
| Contig N50             | 4.3 Mb     |
| Contig L50             | 6          |
| GC percent             | 49%        |
| Genome coverage        | 161.01x    |
| Assembly level         | Scaffold   |

---

### Results
**Read Quality (NanoStat)**

| Metric | Value |
|---|---|
| Total reads | 1,305,000 |
| Total bases | 9,870.2 Mb |
| Median read length | 7,038 bp |
| Read N50 | 10,420 bp |
| Median quality (Phred) | Q14.2 |

**Assembly Statistics (QUAST)**

| Metric | Nessie output | Reference (GenBank) |
|---|---|---|
| Assembly length | 60.1 Mb | 59.4 Mb |
| N50 | 4,946.1 Kbp | 4.3 Mb (contig) |
| L50 | — | 6 |
| Largest contig | 8,340.1 Kbp | — |
| Assembly level | Contig | Scaffold |

**Genome Completeness (BUSCO)**

| Metric | Value |
|---|---|
| Lineage | hypocreales_odb10 |
| Complete single-copy BUSCOs | 4,336 |
| Missing BUSCOs | 109 |
| BUSCO version | 6.0.0 |

---

## Test run 2: _Eulemur rufifrons_ (in progress)

### Data Information
| Field      | Value                    |
|------------|--------------------------|
| Bioproject | SAMN41050454            |
| SRA        | SRR28775784              |
| Platform   | Oxford Nanopore          |
| Model      | MinION               |
| Submitter  | Rutgers, The State University of New Jersey |
| Date       | 2024-10-17               |

### Assembly statistics
| Metric                 | Value       |
|------------------------|-------------|
| Source                 | GenBank     |
| Assembly name          | GCA_043251655.1|
| Genome size            | 2.2 Gb      |
| Total ungapped length  | 2.1 Gb      |
| Number of chromosomes  | 28          |
| Number of organelles   | 1           |
| Number of scaffolds    | 2,980       |
| Scaffold N50           | 101.7 Mb    |
| Scaffold L50           | 8           |
| Number of contigs      | 6,576       |
| Contig N50             | 1.6 Mb      |
| Contig L50             | 397         |
| GC percent             | 41%         |
| Assembly level         | Chromosome  |

---

### Results


**Read Quality (NanoStat)**

| Metric | Value |
|---|---|
| Total reads | 36,553,700 |
| Total bases | 57,550.9 Mb |
| Median read length | 795 bp |
| Read N50 | 2,611 bp |
| Median quality (Phred) | Q13.9 |


**Assembly Statistics (QUAST)**

| Metric | Nessie output | Reference (GenBank) |
|---|---|---|
| Assembly length | 2,271.9 Mb | 2.2 Gb |
| N50 | 1,207.1 Kbp | 1.6 Mb (contig) |
| L50 | 600 | 397 |
| Largest contig | 7,257.0 Kbp | — |
| Assembly level | Contig | Chromosome |


**Genome Completeness (BUSCO)**

| Metric | Value |
|---|---|
| Lineage | primates_odb10 |
| Complete BUSCOs | 13,125 (95.2%) |
| Complete single-copy BUSCOs | 12,957 (94.0%) |
| Complete duplicated BUSCOs | 168 (1.2%) |
| Fragmented BUSCOs | 206 (1.5%) |
| Missing BUSCOs | 449 (3.3%) |
| Total BUSCO groups searched | 13,780 |
| BUSCO version | 6.0.0 |

---