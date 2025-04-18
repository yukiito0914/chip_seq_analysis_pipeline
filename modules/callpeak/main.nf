#!/usr/bin/env nextflow

process CALLPEAK {
    label 'process_high'
    conda './envs/macs3_env.yml'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(ip_bam), path(ip_idx), path(input_bam), path(input_idx)

    output:
    tuple val(meta), path("callpeak_${meta}/"), emit: peak

    shell:
    """
    mkdir -p callpeak_${meta}
    macs3 callpeak -t $ip_bam -c $input_bam -f BAM -g hs -n ${meta} --outdir callpeak_${meta}/
    """
}