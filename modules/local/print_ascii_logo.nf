process PRINT_ASCII_LOGO {
    tag "${logo}"
    label 'process_single'
    container 'docker.io/ubuntu:24.04'

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
