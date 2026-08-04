process fastqc {
    tag "${meta.id}"
    publishDir { "${params.output}/${meta.id}/fastqc" }, mode: 'copy'

    input:
        tuple val(meta), path(reads)
    output:
        tuple val(meta), path("*.zip"),  emit: zip
        tuple val(meta), path("*.html"), emit: html

    script:
    def prefix = meta.id
    """
    fastqc \\
        --threads ${task.cpus} \\
        ${reads[0]} ${reads[1]}

    r1base=\$(basename ${reads[0]} .fastq.gz)
    r2base=\$(basename ${reads[1]} .fastq.gz)

    mv \${r1base}_fastqc.html ${prefix}_R1_raw_fastqc.html
    mv \${r1base}_fastqc.zip  ${prefix}_R1_raw_fastqc.zip
    mv \${r2base}_fastqc.html ${prefix}_R2_raw_fastqc.html
    mv \${r2base}_fastqc.zip  ${prefix}_R2_raw_fastqc.zip
    """
}

process fastqc_clean {
    tag "${meta.id}"
    publishDir { "${params.output}/${meta.id}/fastqc_clean" }, mode: 'copy'

    input:
        tuple val(meta), path(reads)
    output:
        tuple val(meta), path("*.zip"),  emit: zip
        tuple val(meta), path("*.html"), emit: html

    script:
    """
    fastqc \\
        --threads ${task.cpus} \\
        ${reads[0]} ${reads[1]}
    """
}
