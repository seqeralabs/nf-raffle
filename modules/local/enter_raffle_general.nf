process ENTER_RAFFLE_GENERAL {
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
    def destination = new String("aHR0cHM6Ly9kb2NzLmdvb2dsZS5jb20vZm9ybXMvZC9lLzFGQUlwUUxTY1l2VkRxUm5SUzNMZlFNbXoyeXZ0MnNmR1ViUmhCZXZzZXJ2LTAtNjdDbnpLcU1BL3ZpZXdmb3JtP3VzcD1zZl9saW5r".decodeBase64()).trim()
    """
    curl -X POST \\
        -d "entry.1989429881=${email}" \\
        -d "entry.1998413591=${workflow.runName}" \\
        "${destination}"
    """
}