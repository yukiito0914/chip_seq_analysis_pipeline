#!/usr/bin/env nextflow

process FINDMOTIF {
    label 'process_high'
    container 'ghcr.io/bf528/homer:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(filtered_peaks)
    path(genome)

    output:
    path("MotifOutput"), emit: motif

    shell:
    """
    mkdir -p MotifOutput
    findMotifsGenome.pl $filtered_peaks $genome MotifOutput/
    """
}