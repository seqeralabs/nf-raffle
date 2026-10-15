#!/usr/bin/env nextflow

include { ENTER_RAFFLE          } from './modules/local/enter_raffle/main'
include { PRINT_PRIVACY_MESSAGE } from './modules/local/print_privacy_message/main'
include { PUBLISH_REPORT        } from './modules/local/publish_report/main'

params {
    help: Boolean = false
    event: String = 'eccb_2026'
    email: String = ''
    affiliation: String = ''
    first_name: String = ''
    last_name: String = ''
    outdir: String = 'results'
    ticket_number_emit_session_id: Boolean = false
}

workflow {
    main:
    // Validate required parameters
    if (!params.email) {
        error("Please provide --email parameter")
    }

    def config_file = file("${projectDir}/event_configs/${params.event}.json", checkIfExists: true)
    def parsed = new groovy.json.JsonSlurper().parse(config_file)
    def config = record(
        event_name         : parsed.event_name,
        help               : parsed.help,
        destination_url    : parsed.destination_url,
        form_fields        : parsed.form_fields,
        required_fields    : parsed.required_fields,
        winner_announcement: parsed.winner_announcement,
    )

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
            error("This event (${params.event}) requires --${fld}")
        }
    }

    def ch_ready = PRINT_PRIVACY_MESSAGE(config)

    // Read platform_enabled here (workflow.session.config is unavailable inside typed processes)
    def platform_enabled = workflow.session.config.navigate('tower.enabled') ?: false

    def participant = record(
        email      : params.email,
        first_name : params.first_name,
        last_name  : params.last_name,
        affiliation: params.affiliation,
    )

    def ch_participant = ch_ready.map { _ready -> participant }
    def ch_entry = ENTER_RAFFLE(
        ch_participant,
        config,
        platform_enabled
    )

    def html_report_template = channel.fromPath("${projectDir}/assets/ticket_template.html")
    def event_name = config.event_name
    def ticket_number = params.ticket_number_emit_session_id
        ? ch_entry.map { entry -> entry.session_id }
        : ch_entry.map { entry -> entry.run_name }
    def winner_announcement = config.winner_announcement ?: ""

    PUBLISH_REPORT(html_report_template, event_name, ticket_number, winner_announcement)

    publish:
    raffle_ticket = PUBLISH_REPORT.out

    onComplete:
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

output {
    raffle_ticket {
        path '.'
        mode 'copy'
    }
}
