process PRINT_ASCII_LOGO {
    tag "${logo}"
    label 'process_single'

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
