process CONGRATULATIONS {
    tag "${congrats}"
    label 'process_single'
    container 'alpine:3.23'

    input:
    path congrats
    val next

    script:
    """
    cat ${congrats}
    """
}
