process ENTER_RAFFLE_ISMB_BOSC {
    tag "$full_name"
    label 'process_single'

    input:
    val(next)
    val(full_name)
    val(email)
    val(institute)

    output:
    val(true)

    script:
    def platform_enabled = session.config.navigate('tower.enabled') ?: false
    def destination = new String(params.map_ismb2024.decodeBase64()).trim()
    """
    curl -X POST \\
        -d "entry.432613242=${full_name}" \\
        -d "entry.1980966312=${email}" \\
        -d "entry.987828547=${institute}" \\
        -d "entry.829116482=${workflow.runName}" \\
        -d "entry.692779728=\$(hostname)" \\
        -d "entry.1988410012=\$(uuidgen)" \\
        -d "entry.1325573418=${platform_enabled}" \\
        "${destination}"
    """
}