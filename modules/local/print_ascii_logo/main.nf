process PRINT_ASCII_LOGO {
    tag "${logo}"
    label 'process_single'
    container 'community.wave.seqera.io/library/sed_coreutils_procps-ng:749edc0a4a6c3ef9'
    conda "${moduleDir}/environment.yml"

    input:
    path logo
    val next

    output:
    val true

    script:
    """
    cat ${logo}
    """
}
