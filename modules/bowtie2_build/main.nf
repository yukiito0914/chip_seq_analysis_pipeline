#!/usr/bin/env nextflow

process BOWTIE2_BUILD {
    label 'process_high'
    container 'ghcr.io/bf528/bowtie2:latest'
    publishDir params.outdir

    input:
    path(genome)

    output:
    path('bowtie2_index'), emit: index
    val genome.baseName, emit: name

    shell:
    """
    mkdir -p bowtie2_index
    bowtie2-build --threads $task.cpus $genome bowtie2_index/${genome.baseName}
    """
}