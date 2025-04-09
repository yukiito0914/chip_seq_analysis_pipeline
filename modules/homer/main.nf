#!/usr/bin/env nextflow

process HOMER {
    label 'process_single'
    container 'ghcr.io/bf528/homer:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(filtered_peak)
    path(genome)
    path(gtf)

    output:
    path("peak_annotation.txt"), emit: annotation

    shell:
    """
    annotatePeaks.pl $filtered_peak $genome -gtf $gtf > peak_annotation.txt
    """
}