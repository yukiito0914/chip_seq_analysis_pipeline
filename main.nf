#!/usr/bin/env nextflow

include {FASTQC} from './modules/fastqc'
include {TRIMMOMATIC} from './modules/trimmomatic'
include {BOWTIE2_BUILD} from './modules/bowtie2_build'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_SORT} from './modules/samtools_sort'
include {SAMTOOLS_IDX} from './modules/samtools_idx'
include {SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include {MULTIQC} from './modules/multiqc'
include {DEEPTOOLS_BAMCOVERAGE} from './modules/deeptools_bamcoverage'
include {MULTIBIGWIGSUMMARY} from './modules/multibigwigsummary'
include {PLOTCORRELATION} from './modules/plotcorrelation'
include {CALLPEAK} from './modules/callpeak'
include {INTERSECT} from './modules/intersect'
include {REMOVE} from './modules/remove'
include {HOMER} from './modules/homer'

workflow {

    Channel.fromPath(params.samplesheet)
    | splitCsv(header: true)
    | map { row -> tuple(row.name, file(row.path)) }
    | set {fq_ch}

    // Perform Quality Control
    FASTQC(fq_ch)
    // Trim reads
    TRIMMOMATIC(fq_ch)
    // Generate a genome index
    BOWTIE2_BUILD(params.genome)
    // Align reads to the genome
    BOWTIE2_ALIGN(TRIMMOMATIC.out.trimmed, BOWTIE2_BUILD.out.index, BOWTIE2_BUILD.out.name)
    // Sort the BAM file
    SAMTOOLS_SORT(BOWTIE2_ALIGN.out.bam)
    // Index the sorted BAM file
    SAMTOOLS_IDX(SAMTOOLS_SORT.out.sorted)
    // Calculate alignment statistics
    SAMTOOLS_FLAGSTAT(SAMTOOLS_SORT.out.sorted)

    FASTQC.out.zip.map{it[1]}
    | set {fastqc_out}

    TRIMMOMATIC.out.log.map{it[1]}
    | set {trimmomatic_log}

    SAMTOOLS_FLAGSTAT.out.flagstat.map{it[1]}
    | set {flagstat_out}

    fastqc_out
        .mix(trimmomatic_log)
        .mix(flagstat_out)
        .flatten()
        .collect()
        | set {multiqc_ch}

    // Perform post-alignment QC
    MULTIQC(multiqc_ch)

    // Perform coverage analysis
    DEEPTOOLS_BAMCOVERAGE(SAMTOOLS_SORT.out.sorted.join(SAMTOOLS_IDX.out.index))

    DEEPTOOLS_BAMCOVERAGE.out.coverage
    . map{it[1]}
    . collect()
    . set {bigwig_ch}

    // Create a matrix containing the information from the bigWig files
    MULTIBIGWIGSUMMARY(bigwig_ch)
    // Plot correlation heatmap
    PLOTCORRELATION(MULTIBIGWIGSUMMARY.out.npz)

    sorted_bam_paths = SAMTOOLS_SORT.out.sorted
    .join(SAMTOOLS_IDX.out.index)
    .map { tuple(it[0], it[1], it[2]) } // tuple(meta, bam, bai)

    sorted_bam_paths
    .map { name, bam, bai -> 
        def rep = name.split('_')[1]
        def tag = bam.baseName.split('_')[0]  // "IP" or "INPUT"
        tuple(rep, [(tag): [bam, bai]])
    }
    .groupTuple(by: 0)
    .map { rep, maps -> tuple(rep, maps[0] + maps[1]) }
    .map { rep, samples -> tuple(rep, samples.IP[0], samples.IP[1], samples.INPUT[0], samples.INPUT[1]) }
    .set { peakcalling_ch }

    // Peak calling
    CALLPEAK(peakcalling_ch)

    CALLPEAK.out.peak
        .map { _, dir -> 
            dir.listFiles().find { it.name.endsWith('.narrowPeak') }
        }
        .collect()
        .map { files -> 
            tuple(files[0], files[1])
        }
        .set { intersect_ch }

    // Intersect reproducible peaks
    INTERSECT(intersect_ch)
    // Remove blacklisted regions
    REMOVE(INTERSECT.out.repr_peaks, params.blacklist)
    // Annotating peaks
    HOMER(REMOVE.out.filtered_peaks, params.genome, params.gtf)
}