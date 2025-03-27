#!/usr/bin/env nextflow

process SAMTOOLS_FLAGSTAT {
    label 'process_single'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path('*flagstat.txt'), emit: flagstat

    shell:
    """
    samtools flagstat $bam > ${meta}_flagstat.txt
    """
}