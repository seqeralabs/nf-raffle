// This process stays untyped for output (workflow.sessionId/runName are unavailable
// in typed processes). The onComplete block in main.nf also uses workflow.session.config.
nextflow.enable.types = true

include { EventConfig ; Participant } from '../../../types'

process ENTER_RAFFLE {
    tag "${participant.email}"
    label 'process_single'
    container 'community.wave.seqera.io/library/curl_util-linux_procps-ng:72cd763bb8c83eca'
    conda "${moduleDir}/environment.yml"

    input:
    participant: Participant
    config: EventConfig
    platform_enabled: Boolean

    output:
    record(
        session_id: workflow.sessionId.toString(),
        run_name: workflow.runName,
    )

    script:
    def email = participant.email
    def affiliation = participant.affiliation
    def first_name = participant.first_name
    def last_name = participant.last_name
    def destination = config.destination_url
    def form_fields = config.form_fields

    // Capture workflow context for demo detection
    def user_name = workflow.userName ?: ''
    def workspace_id = System.getenv('TOWER_WORKSPACE_ID') ?: ''
    def platform_workflow_id = System.getenv('TOWER_WORKFLOW_ID') ?: ''

    // Built as immutable list (typed processes don't allow << or add)
    def curl_args = [
        form_fields.email ? "-d \"${form_fields.email}=${email}\"" : '',
        form_fields.run_name ? "-d \"${form_fields.run_name}=${workflow.runName}\"" : '',
        form_fields.hostname ? "-d \"${form_fields.hostname}=\$(hostname)\"" : '',
        form_fields.uuid ? "-d \"${form_fields.uuid}=\$(uuidgen)\"" : '',
        form_fields.platform_enabled ? "-d \"${form_fields.platform_enabled}=${platform_enabled}\"" : '',
        form_fields.affiliation && affiliation ? "-d \"${form_fields.affiliation}=${affiliation}\"" : '',
        form_fields.first_name && first_name ? "-d \"${form_fields.first_name}=${first_name}\"" : '',
        form_fields.last_name && last_name ? "-d \"${form_fields.last_name}=${last_name}\"" : '',
        form_fields.user_name ? "-d \"${form_fields.user_name}=${user_name}\"" : '',
        form_fields.workspace_id ? "-d \"${form_fields.workspace_id}=${workspace_id}\"" : '',
        form_fields.platform_workflow_id ? "-d \"${form_fields.platform_workflow_id}=${platform_workflow_id}\"" : '',
    ]
    def curl_data = curl_args.findAll { arg -> arg != '' }.join(' ')

    """
    curl -X POST ${curl_data} "${destination}"
    """
}
