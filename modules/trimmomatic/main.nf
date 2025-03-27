#!/usr/bin/env nextflow

process TRIMMOMATIC {
    container 'ghcr.io/bf528/trimmomatic:latest'
    label 'process_low'
    publishDir params.outdir

    input:
    tuple val(name), path(fastq)

    output:
    tuple val(name), path('*_trimmed.fastq.gz'), emit: trimmed
    tuple val(name), path("*.log"), emit: log

    shell:
    """
    trimmomatic SE -threads $task.cpus -trimlog ${name}_trim.log -phred33 $fastq ${name}_trimmed.fastq.gz ILLUMINACLIP:TruSeq3-SE:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    """
}