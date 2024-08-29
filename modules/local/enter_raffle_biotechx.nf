process ENTER_RAFFLE_BIOTECHX {
    tag "$email"
    label 'process_single'

    input:
    val(next)
    val(email)

    output:
    val(true)

    script:
    def platform_enabled = session.config.navigate('tower.enabled') ?: false
    def destination = new String("aHR0cHM6Ly9kb2NzLmdvb2dsZS5jb20vZm9ybXMvdS8wL2QvZS8xRkFJcFFMU2VvTWpTVzdndDg4V09HUENkeTNoVC0tUnIyUkpfZHA5eUlRVTFGMlNPaFEtNXh2dy9mb3JtUmVzcG9uc2U=".decodeBase64()).trim()
    """
    curl -X POST \\
        -d "entry.1764797758=${email}" \\
        -d "entry.957741798=${workflow.runName}" \\
        -d "entry.1283336320=\$(uuidgen)" \\
        -d "entry.524404923=${platform_enabled}" \\
        "${destination}"
    """
}