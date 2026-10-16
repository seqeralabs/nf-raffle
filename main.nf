#!/usr/bin/env nextflow

nextflow.enable.types = true

include { paramsHelp ; validateParameters } from 'plugin/nf-schema'
include { loadEventConfig ; towerConfig } from './utils'
include { ENTER_RAFFLE          } from './modules/local/enter_raffle/main'
include { PRINT_PRIVACY_MESSAGE } from './modules/local/print_privacy_message/main'
include { PUBLISH_REPORT        } from './modules/local/publish_report/main'

params {
    help: Boolean = false
    event: String = 'ashg_2026'
    email: String = ''
    affiliation: String = ''
    first_name: String = ''
    last_name: String = ''
    outdir: String = 'results'
    ticket_number_emit_session_id: Boolean = false
    // Test-only: path to an event config that replaces event_configs/<event>.json (see the `test` profile).
    event_config: String = ''
}

workflow {
    main:
    if (params.help) {
        log.info(paramsHelp())
        exit(0, null)
    }

    validateParameters()

    if (!params.email) {
        error("Please provide --email parameter")
    }

    def config = loadEventConfig(params.event_config ?: "${projectDir}/event_configs/${params.event}.json")

    // Any field marked Required in the event's Google Form must be listed in
    // required_fields so the pipeline always sends a value: Google Forms
    // silently drops submissions that leave a Required question empty.
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

    def platform_enabled = (towerConfig()['enabled'] ?: false) as Boolean

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
    def ticket_number = params.ticket_number_emit_session_id
        ? ch_entry.map { entry -> entry.session_id }
        : ch_entry.map { entry -> entry.run_name }

    def ch_ticket = PUBLISH_REPORT(html_report_template, config.event_name, ticket_number, config.winner_announcement ?: "")

    publish:
    raffle_ticket = ch_ticket

    onComplete:
    def tower = towerConfig()
    def towerEnabled = tower['enabled'] as Boolean
    def towerToken = (tower['accessToken'] ?: env('TOWER_ACCESS_TOKEN')) as String

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
