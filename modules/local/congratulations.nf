process CONGRATULATIONS {
    tag "${congrats}"
    label 'process_single'

    input:
    path congrats
    val next

    script:
    """
    cat ${congrats}
    """
}
