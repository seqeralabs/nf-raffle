#!/usr/bin/env nextflow

include { ENTER_RAFFLE          } from './modules/local/enter_raffle/main'
include { PRINT_PRIVACY_MESSAGE } from './modules/local/print_privacy_message/main'
include { PUBLISH_REPORT        } from './modules/local/publish_report/main'

def printPrivacyMessage() {
    // Check if Tower/Platform is disabled or access token is missing
    def towerEnabled = workflow.session.config.navigate('tower.enabled') ?: false
    def towerToken = workflow.session.config.navigate('tower.accessToken') ?: System.getenv('TOWER_ACCESS_TOKEN')

    if (!towerEnabled || !towerToken) {
        return """
        =====================================
        Win more entries to the raffle!
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
        return """
        ============================================
        You earned extra raffle tickets!
        ============================================

        Because you used Seqera Platform for this workflow,
        you have received additional entries to the raffle.

        Thank you for using Seqera Platform and good luck!
        ============================================
        """.stripIndent()
    }
}

workflow NF_RAFFLE {
    take:
    email
    config
    html_report_template

    main:
    // Print privacy policy information
    PRINT_PRIVACY_MESSAGE()

    // Standard raffle entry for all events
    ENTER_RAFFLE(
        PRINT_PRIVACY_MESSAGE.out,
        email,
        config
    )

    // Generate ticket
    def event_name = config.event_name
    def ticket_number = params.ticket_number_emit_session_id ? ENTER_RAFFLE.out.session_id : ENTER_RAFFLE.out.run_name

    PUBLISH_REPORT(html_report_template, event_name, ticket_number)

    emit:
    raffle_ticket = PUBLISH_REPORT.out
}

workflow {
    main:
    // Default event to ASHG 2025 if not specified
    def event = params.event ?: 'ashg_2025'

    // Validate required parameters
    if (!params.email) {
        error("Please provide --email parameter")
    }

    // Load event configuration
    def config_file = file("${projectDir}/event_configs/${event}.json", checkIfExists: true)
    def config = new groovy.json.JsonSlurper().parse(config_file)

    // Create input channels
    ch_email = Channel.value(params.email)
    ch_config = Channel.value(config)
    ch_template = Channel.fromPath("${projectDir}/assets/ticket_template.html")

    // Run the main workflow
    NF_RAFFLE(ch_email, ch_config, ch_template)

    publish:
    raffle_ticket = NF_RAFFLE.out.raffle_ticket
}

output {
    raffle_ticket {
        path '.'
    }
}

workflow.onComplete {
    println printPrivacyMessage()
}