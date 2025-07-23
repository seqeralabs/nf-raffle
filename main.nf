#!/usr/bin/env nextflow

include { ENTER_RAFFLE          } from './modules/local/enter_raffle'
include { PRINT_PRIVACY_MESSAGE } from './modules/local/print_privacy_message'
include { PUBLISH_REPORT        } from './modules/local/publish_report'

workflow {
    // Default event to ismb_2025 if not specified
    def event = params.event ?: 'ismb_2025'

    // Validate required parameters
    if (!params.email) {
        error("Please provide --email parameter")
    }

    // Load event configuration
    config_file = file("${projectDir}/event_configs/${event}.json", checkIfExists: true)

    def config = new groovy.json.JsonSlurper().parse(config_file)

    // Print privacy policy information
    PRINT_PRIVACY_MESSAGE()

    // Standard raffle entry for all events
    ENTER_RAFFLE(
        PRINT_PRIVACY_MESSAGE.out,
        params.email,
        config
    )

    // Generate ticket
    html_report = Channel.fromPath("${projectDir}/assets/ticket_template.html")
    event_name = config.event_name
    ticket_number = params.ticket_number_emit_session_id ? ENTER_RAFFLE.out.session_id : ENTER_RAFFLE.out.run_name

    PUBLISH_REPORT(html_report, event_name, ticket_number)
}
