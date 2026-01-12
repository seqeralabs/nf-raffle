process PRINT_ASCII_LOGO {
    tag "${logo}"
    label 'process_single'
    container 'alpine:3.23'

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
