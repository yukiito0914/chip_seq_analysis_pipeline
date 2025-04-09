#!/usr/bin/env nextflow

process INTERSECT {
    label 'process_single'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple path(peak1), path(peak2)

    output:
    path("reproducible_peaks.bed"), emit: repr_peaks

    shell:
    """
    bedtools intersect -a $peak1 -b $peak2 -f 0.5 -r > reproducible_peaks.bed
    """
}