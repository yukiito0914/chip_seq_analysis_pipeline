# ChIP-seq Analysis Pipeline
This Nextflow pipeline processes ChIP-seq data from raw FASTQ files through quality control, trimming, alignment, peak calling, reproducibility filtering, coverage analysis, annotation, and motif discovery. The pipeline is modular and reproducible, supporting both Singularity and Conda.

## Pipeline Overview
FASTQ → Quality Control → Trimming → Alignment → BAM Processing → Coverage Analysis → Peak Calling → Reproducibility Filtering → Annotation → Motif Discovery → Signal Profiling

## Pipeline Modules
| Step                     | Tool(s)           | Description                                                             |
|--------------------------|-------------------|-------------------------------------------------------------------------|
| Quality Control          | `FASTQC`, `MULTIQC` | Assess raw and trimmed read quality                                    |
| Trimming                 | `TRIMMOMATIC`      | Remove adapters and low-quality bases                                  |
| Genome Indexing          | `BOWTIE2_BUILD`     | Build genome index for alignment                                       |
| Alignment                | `BOWTIE2_ALIGN`     | Map reads to the reference genome                                      |
| BAM Processing           | `SAMTOOLS_SORT`, `SAMTOOLS_IDX`, `SAMTOOLS_FLAGSTAT` | Sort, index, and generate alignment stats for BAM files |
| Coverage Analysis        | `DEEPTOOLS_BAMCOVERAGE`, `MULTIBIGWIGSUMMARY`, `PLOTCORRELATION` | Generate bigWig files and assess sample correlation     |
| Peak Calling             | `CALLPEAK`         | Call peaks using MACS2                                                 |
| Reproducibility Filtering| `INTERSECT`        | Intersect peaks across replicates                                      |
| Blacklist Filtering      | `REMOVE`           | Remove blacklisted genomic regions                                     |
| Annotation               | `HOMER`            | Annotate peaks with gene features                                      |
| Motif Discovery          | `FINDMOTIF`        | Identify enriched sequence motifs near peaks                           |
| Signal Profiling         | `COMPUTEMATRIX`, `PLOTPROFILE` | Plot ChIP enrichment across genomic features              |

## Input Requirement
| Parameter           | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `params.samplesheet`     | CSV file with sample names and paths to FASTQ files                         |
| `params.adapter_fa`      | Adapter sequence file for trimming (e.g. Illumina TruSeq)                   |
| `params.genome`          | Reference genome in FASTA format (e.g. GRCh38)                              |
| `params.gtf`             | Gene annotation file in GTF format (e.g. GENCODE)                           |
| `-params.blacklist`       | BED file of blacklisted genomic regions to be removed from peak calls       |
| `params.bed`             | BED file of regions for signal profiling (e.g. promoters, TSS)              |

