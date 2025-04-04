#!/usr/bin/env nextflow

process MULTIBIGWIGSUMMARY {
    label 'process_medium'
    container 'ghcr.io/bf528/deeptools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path(coverage)

    output:
    path("coverage_summary.npz"), emit: npz

    shell:
    """
    multiBigwigSummary bins -b ${coverage.join(' ')} -o coverage_summary.npz -p $task.cpus
    """
}