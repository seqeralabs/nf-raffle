process ENTER_RAFFLE {
    tag "${email}"
    label 'process_single'

    input:
    val next
    val email
    val config_map

    output:
    val workflow.sessionId, emit: session_id
    val workflow.runName, emit: run_name

    script:
    def platform_enabled = workflow.session.config.navigate('tower.enabled') ?: false
    def destination = config_map.destination_url
    def form_fields = config_map.form_fields

    // Build curl data arguments using nf-core style
    def email_cmd = form_fields.email ? "-d \"${form_fields.email}=${email}\"" : ""
    def run_name_cmd = form_fields.run_name ? "-d \"${form_fields.run_name}=${workflow.runName}\"" : ""
    def hostname_cmd = form_fields.hostname ? "-d \"${form_fields.hostname}=\$(hostname)\"" : ""
    def uuid_cmd = form_fields.uuid ? "-d \"${form_fields.uuid}=\$(uuidgen)\"" : ""
    def platform_cmd = form_fields.platform_enabled ? "-d \"${form_fields.platform_enabled}=${platform_enabled}\"" : ""

    """
    curl -X POST \\
        ${email_cmd} \\
        ${run_name_cmd} \\
        ${hostname_cmd} \\
        ${uuid_cmd} \\
        ${platform_cmd} \\
        "${destination}"
    """
}
