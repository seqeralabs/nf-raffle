process CONGRATULATIONS {
    tag "${congrats}"
    label 'process_single'
    container 'ubuntu:24.04'

    input:
    path congrats
    val next

    script:
    """
    cat ${congrats}
    """
}
