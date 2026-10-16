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
    // Values are shell-quoted, except uuid and hostname, which the task shell evaluates.
    // Only fields that the event's form_fields maps to an entry ID are sent, and
    // empty values are skipped, so an event can leave out any optional question
    // (e.g. the staff-demo fields user_name, hostname, workspace_id, platform_workflow_id).
    def values = [
        email               : shellQuote(participant.email),
        first_name          : shellQuote(participant.first_name),
        last_name           : shellQuote(participant.last_name),
        affiliation         : shellQuote(participant.affiliation),
        run_name            : shellQuote(workflow.runName),
        uuid                : '"$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)"',
        platform_enabled    : shellQuote(platform_enabled.toString()),
        hostname            : '"$(hostname)"',
        user_name           : shellQuote(workflow.userName),
        workspace_id        : shellQuote(env('TOWER_WORKSPACE_ID')),
        platform_workflow_id: shellQuote(env('TOWER_WORKFLOW_ID')),
    ]
    def curl_data = values.keySet()
        .findAll { fld -> config.form_fields[fld] && values[fld] }
        .collect { fld -> "--data-urlencode ${config.form_fields[fld]}=${values[fld]}" }
        .join(' \\\n        ')

    """
    curl --fail-with-body -sS -w '\\nHTTP status: %{http_code}\\n' -X POST \\
        ${curl_data} \\
        '${config.destination_url}'
    """
}

def shellQuote(value: String?) -> String {
    return value ? "'" + value.replace("'", "'\\''") + "'" : ''
}
