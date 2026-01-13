process CONGRATULATIONS {
    tag "${congrats}"
    label 'process_single'
    container 'community.wave.seqera.io/library/sed_coreutils_procps-ng:749edc0a4a6c3ef9'
    conda "sed coreutils procps-ng"

    input:
    path congrats
    val next

    script:
    """
    cat ${congrats}
    """
}
