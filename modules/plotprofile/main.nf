#!/usr/bin/env nextflow

process PLOTPROFILE {
    label 'process_single'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(matrix)

    output:
    tuple val(meta), path("*_profile.png"), emit: plot

    shell:
    """
    plotProfile -m $matrix -o ${meta}_profile.png
    """
}