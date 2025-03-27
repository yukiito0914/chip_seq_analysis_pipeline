#!/usr/bin/env nextflow

process BOWTIE2_ALIGN {
    //label 'process_high'
    container 'ghcr.io/bf528/bowtie2:latest'

    input:
    tuple val(meta), path(reads)
    path bt2
    val name

    output:
    tuple val(meta), path('*bam'), emit: bam

    shell:
    """
    bowtie2 --very-fast -p $task.cpus -x $bt2/$name -U $reads | samtools view -bS - > ${meta}.bam
    """
}