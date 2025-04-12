#!/usr/bin/env nextflow

process COMPUTEMATRIX {
    label 'process_high'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(bigWig)
    path(bed)

    output:
    tuple val(meta), path("*.gz"), emit: matrix

    shell:
    """
    computeMatrix scale-regions -S $bigWig -R $bed -b 2000 -o ${meta}.gz 
    """
}