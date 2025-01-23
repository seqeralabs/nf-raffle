process FOG25 {
    tag "$email"
    label 'process_single'

    input:
    val(next)
    val(email)

    output:
    val(workflow.sessionId), emit: session_id
    val(workflow.runName)  , emit: run_name

    script:
    def platform_enabled = session.config.navigate('tower.enabled') ?: false
    def destination = new String("aHR0cHM6Ly9kb2NzLmdvb2dsZS5jb20vZm9ybXMvdS8wL2QvZS8xRkFJcFFMU2MxUGNMVURHaXlIOHFJMDhrcU12eTRaV0UyWEVIeGFLemZDLUFaT25oY3pvSjFGQS9mb3JtUmVzcG9uc2U=".decodeBase64()).trim()
    """
    curl -X POST \\
        -d "entry.1829806584=${email}" \\
        -d "entry.55593741=${workflow.runName}" \\
        -d "entry.1298715334=\$(hostname)" \\
        -d "entry.2075010812=${platform_enabled}" \\
        "${destination}"
    """
}