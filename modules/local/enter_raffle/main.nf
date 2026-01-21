process ENTER_RAFFLE {
    tag "${email}"
    label 'process_single'
    container 'community.wave.seqera.io/library/curl_util-linux_procps-ng:72cd763bb8c83eca'
    conda "${moduleDir}/environment.yml"

    input:
    val next
    val email
    val affiliation
    val config

    output:
    val workflow.sessionId, emit: session_id
    val workflow.runName, emit: run_name

    script:
    def platform_enabled = workflow.session.config.navigate('tower.enabled') ?: false
    def destination = config.destination_url
    def form_fields = config.form_fields

    // Capture workflow context for demo detection
    def user_name = workflow.userName ?: ''
    def workspace_id = System.getenv('TOWER_WORKSPACE_ID') ?: ''
    def platform_workflow_id = System.getenv('TOWER_WORKFLOW_ID') ?: ''

    // Build curl data arguments - collect non-empty args into a list
    def curl_args = []
    if (form_fields.email) curl_args << "-d \"${form_fields.email}=${email}\""
    if (form_fields.run_name) curl_args << "-d \"${form_fields.run_name}=${workflow.runName}\""
    if (form_fields.hostname) curl_args << "-d \"${form_fields.hostname}=\$(hostname)\""
    if (form_fields.uuid) curl_args << "-d \"${form_fields.uuid}=\$(uuidgen)\""
    if (form_fields.platform_enabled) curl_args << "-d \"${form_fields.platform_enabled}=${platform_enabled}\""
    if (form_fields.affiliation && affiliation) curl_args << "-d \"${form_fields.affiliation}=${affiliation}\""
    if (form_fields.user_name) curl_args << "-d \"${form_fields.user_name}=${user_name}\""
    if (form_fields.workspace_id) curl_args << "-d \"${form_fields.workspace_id}=${workspace_id}\""
    if (form_fields.platform_workflow_id) curl_args << "-d \"${form_fields.platform_workflow_id}=${platform_workflow_id}\""
    def curl_data = curl_args.join(' ')

    """
    curl -X POST ${curl_data} "${destination}"
    """
}
