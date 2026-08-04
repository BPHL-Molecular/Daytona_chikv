process qc_gate {
    tag "${meta.id}"
    publishDir { "${params.output}/assemblies_qc_pass" }, mode: 'copy', pattern: "*.consensus.fasta"

    input:
        tuple val(meta), path(consensus), path(coverage)
    output:
        tuple val(meta), path("${meta.id}_qc.tsv"),        emit: qc
        path "${meta.id}.consensus.fasta", optional: true, emit: pass_fasta

    script:
    def prefix = meta.id
    """
    qc_gate.py \\
        --sample-id ${prefix} \\
        --consensus ${consensus} \\
        --coverage  ${coverage} \\
        --output    ${meta.id}_qc.tsv
    """
}
