process CONGRATULATIONS {
    tag "${congrats}"
    label 'process_single'
    conda "${projectDir}/envs/basic-utils.yml"

    input:
    path congrats
    val next

    script:
    """
    cat ${congrats}
    """
}
