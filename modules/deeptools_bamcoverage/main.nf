#!/usr/bin/env nextflow

process DEEPTOOLS_BAMCOVERAGE {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(sorted_bam), path(index)

    output:
    tuple val(meta), path("*coverage.bw"), emit: coverage

    shell:
    """
    bamCoverage -b $sorted_bam -o ${meta}_coverage.bw -p $task.cpus
    """
}