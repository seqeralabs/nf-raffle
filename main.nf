#!/usr/bin/env nextflow

include { ENTER_RAFFLE          } from './modules/local/enter_raffle'
include { PRINT_PRIVACY_MESSAGE } from './modules/local/print_privacy_message'
include { PUBLISH_REPORT        } from './modules/local/publish_report'

workflow {
    // Default event to biotechx_2025 if not specified
    def event = params.event ?: 'biotechx_2025'

    // Validate required parameters
    if (!params.email) {
        error("Please provide --email parameter")
    }

    // Load event configuration
    def config_file = file("${projectDir}/event_configs/${event}.json", checkIfExists: true)

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
    html_report_template = Channel.fromPath("${projectDir}/assets/ticket_template.html")
    event_name = config.event_name
    ticket_number = params.ticket_number_emit_session_id ? ENTER_RAFFLE.out.session_id : ENTER_RAFFLE.out.run_name

    PUBLISH_REPORT(html_report_template, event_name, ticket_number)

    workflow.onComplete = {
        // Check if Tower/Platform is disabled or access token is missing
        def towerEnabled = session.config.navigate('tower.enabled') ?: false
        def towerToken = session.config.navigate('tower.accessToken') ?: System.getenv('TOWER_ACCESS_TOKEN')

        if (!towerEnabled || !towerToken) {
            log.warn """
            =====================================
            💡 Win more entries to the raffle! 💡
            =====================================

            Create a free account on https://cloud.seqera.io/ to get additional raffle entries!
            Simply enable Seqera Platform monitoring by either:

            1. Adding to your nextflow.config:
            tower {
                enabled     = true
                accessToken = 'your-token-here'
            }

            2. Or set the environment variable:
            export TOWER_ACCESS_TOKEN='your-token-here'

            =====================================
            """.stripIndent()
        }
    }
}
