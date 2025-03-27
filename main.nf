#!/usr/bin/env nextflow

include {FASTQC} from './modules/fastqc'
include {TRIMMOMATIC} from './modules/trimmomatic'
include {BOWTIE2_BUILD} from './modules/bowtie2_build'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_SORT} from './modules/samtools_sort'
include {SAMTOOLS_IDX} from './modules/samtools_idx'
include {SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include {MULTIQC} from './modules/multiqc'
include {DEEPTOOLS_BAMCOVERAGE} from './modules/deeptools_bamcoverage'

workflow {

    Channel.fromPath(params.subset_samplesheet)
    | splitCsv(header: true)
    | map { row -> tuple(row.name, file(row.path)) }
    | set {fq_ch}

    // Perform Quality Control
    FASTQC(fq_ch)
    // Trim reads
    TRIMMOMATIC(fq_ch)
    // Generate a genome index
    BOWTIE2_BUILD(params.genome)
    // Align reads to the genome
    BOWTIE2_ALIGN(TRIMMOMATIC.out.trimmed, BOWTIE2_BUILD.out.index, BOWTIE2_BUILD.out.name)
    // Sort the BAM file
    SAMTOOLS_SORT(BOWTIE2_ALIGN.out.bam)
    // Index the sorted BAM file
    SAMTOOLS_IDX(SAMTOOLS_SORT.out.sorted)
    // Calculate alignment statistics
    SAMTOOLS_FLAGSTAT(SAMTOOLS_SORT.out.sorted)

    FASTQC.out.zip.map{it[1]}
    | set {fastqc_out}

    TRIMMOMATIC.out.log.map{it[1]}
    | set {trimmomatic_log}

    SAMTOOLS_FLAGSTAT.out.flagstat.map{it[1]}
    | set {flagstat_out}

    fastqc_out
        .mix(trimmomatic_log)
        .mix(flagstat_out)
        .flatten()
        .collect()
        | set {multiqc_ch}

    // Perform post-alignment QC
    MULTIQC(multiqc_ch)

    // Perform coverage analysis
    DEEPTOOLS_BAMCOVERAGE(SAMTOOLS_SORT.out.sorted.join(SAMTOOLS_IDX.out.index))
}
