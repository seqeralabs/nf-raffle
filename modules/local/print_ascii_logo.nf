process PRINT_ASCII_LOGO {
    tag "${logo}"
    label 'process_single'
    conda "${projectDir}/envs/basic-utils.yml"

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
