#!/usr/bin/env nextflow

include { ENTER_RAFFLE          } from './modules/local/enter_raffle/main'
include { PRINT_PRIVACY_MESSAGE } from './modules/local/print_privacy_message/main'
include { PUBLISH_REPORT        } from './modules/local/publish_report/main'

workflow {
    // Default event to ECCB 2026 if not specified
    def event = params.event ?: 'eccb_2026'

    // Validate required parameters
    if (!params.email) {
        error("Please provide --email parameter")
    }

    // Load event configuration
    def config_file = file("${projectDir}/event_configs/${event}.json", checkIfExists: true)

    def config = new groovy.json.JsonSlurper().parse(config_file)

    // Validate participant-supplied fields this event marks as required. The
    // required_fields list is per-event, so other events are unaffected
    // (e.g. fog_2026 keeps affiliation optional). Any field marked Required in
    // the event's Google Form must be listed here so the pipeline always sends
    // a value and the form's required-field validation never rejects the entry.
    def required_field_params = [
        email      : params.email,
        first_name : params.first_name,
        last_name  : params.last_name,
        affiliation: params.affiliation,
    ]
    config.required_fields?.each { fld ->
        if (required_field_params.containsKey(fld) && !required_field_params[fld]) {
            error("This event (${event}) requires --${fld}")
        }
    }

    // Print privacy policy information
    PRINT_PRIVACY_MESSAGE(config)

    // Standard raffle entry for all events
    ENTER_RAFFLE(
        PRINT_PRIVACY_MESSAGE.out,
        params.email,
        params.affiliation,
        params.first_name,
        params.last_name,
        config
    )

    // Generate ticket
    html_report_template = Channel.fromPath("${projectDir}/assets/ticket_template.html")
    event_name = config.event_name
    ticket_number = params.ticket_number_emit_session_id ? ENTER_RAFFLE.out.session_id : ENTER_RAFFLE.out.run_name

    winner_announcement = config.winner_announcement ?: ""
    PUBLISH_REPORT(html_report_template, event_name, ticket_number, winner_announcement)

    workflow.onComplete = {
        // Check if Tower/Platform is disabled or access token is missing
        def towerEnabled = workflow.session.config.navigate('tower.enabled') ?: false
        def towerToken = workflow.session.config.navigate('tower.accessToken') ?: System.getenv('TOWER_ACCESS_TOKEN')

        if (!towerEnabled || !towerToken) {
            log.warn """
            =====================================
            💡 Win more entries to the raffle! 💡
            =====================================

            Create a free account on https://cloud.seqera.io/ to get additional raffle entries!
            Simply enable Seqera Platform monitoring by:

            1. Create an account on https://cloud.seqera.io/

            2. Create an access token at https://cloud.seqera.io/tokens

            3. Adding to your nextflow.config:
            tower {
                enabled     = true
                accessToken = 'your-token-here'
            }

            4. Run the pipeline with the additional configuration:
            nextflow run seqeralabs/nf-raffle --email <your email> -c nextflow.config

            =====================================
            """.stripIndent()
        } else {
            log.info """
            ============================================\n
            🎉 You earned extra raffle tickets! 🎉
            ============================================

            Because you used Seqera Platform for this workflow,
            you have received additional entries to the raffle.

            Thank you for using Seqera Platform and good luck!
            ============================================
            """.stripIndent()
        }
    }
}
