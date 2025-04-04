#!/usr/bin/env nextflow

process PLOTCORRELATION {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(matrix)

    output:
    path("spearman_heatmap.png"), emit: heatmap

    shell:
    """
    plotCorrelation -in $matrix -c spearman -p heatmap -o spearman_heatmap.png
    """
}