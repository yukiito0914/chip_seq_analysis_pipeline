#!/usr/bin/env nextflow

process REMOVE {
    label 'process_single'
    container 'ghcr.io/bf528/bedtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(repr_peak)
    path(blacklist)

    output:
    path("peak.filtered.bed"), emit: filtered_peaks

    shell:
    """
    bedtools intersect -v -a $repr_peak -b $blacklist > peak.filtered.bed
    """
}