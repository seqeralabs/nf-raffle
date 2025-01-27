#!/usr/bin/env nextflow

include { ISMB_BOSC_2024 } from './workflows/ismb_bosc_2024'
include { BIOTECHX_2024  } from './workflows/biotechx_basel_2024'
include { ASHG_2024 }      from './workflows/ashg_2024'
include { PUBLISH_REPORT } from './modules/local/publish_report'
include { FOG25_WORKFLOW } from './workflows/fog_2025'
include { SLAS_2025      } from './workflows/slas_2025'

workflow {
    main:
    ascii       = Channel.fromPath("${projectDir}/assets/ismb_bosc2024/ismb_bosc_ascii_art.txt")
    congrats    = Channel.fromPath("${projectDir}/assets/congratulations.txt")
    html_report = Channel.fromPath("${projectDir}/assets/ticket_template.html")

    // Input validation
    if (!params.event) {
        error "Please specify an event using --event parameter"
    }

    // Event selection
    switch(params.event) {
        case "ismb_bosc2024":
            if (!params.name || !params.email || !params.institute) {
                error "Please provide --name, --email, and --institute parameters for ISMB/BOSC 2024"
            }
            ISMB_BOSC_2024(ascii, congrats)

            event = "ISMB\\/BOSC 2024"
            ticket_number = params.ticket_number_emit_session_id ? ISMB_BOSC_2024.out.session_id : ISMB_BOSC_2024.out.run_name
            break

        case "biotechx_basel_2024":
            if (!params.email) {
                error "Please provide --email parameter to enter the raffle at BiotechX Basel 2024."
            }
            BIOTECHX_2024()
            event = "BiotechX BASEL 2024"
            ticket_number = params.ticket_number_emit_session_id ? BIOTECHX_2024.out.session_id : BIOTECHX_2024.out.run_name

            break
        case "ashg_2024":
            if (!params.email) {
                error "Please provide --email parameter to enter the raffle at ASHG 2024."
            }
            ASHG_2024()
            event = "ASHG 2024"
            ticket_number = params.ticket_number_emit_session_id ? ASHG_2024.out.session_id : ASHG_2024.out.run_name
            break
        case "fog_2025":
            if (!params.email) {
                error "Please provide --email parameter to enter the raffle at FOG 2025."
            }
            FOG25_WORKFLOW()
            event = "FOG 2025"
            ticket_number = params.ticket_number_emit_session_id ? FOG25_WORKFLOW.out.session_id : FOG25_WORKFLOW.out.run_name
            break
        case "slas_2025":
            if (!params.email) {
                error "Please provide --email parameter to enter the raffle at SLAS 2025."
            }
            SLAS_2025()
            event = "SLAS 2025"
            ticket_number = params.ticket_number_emit_session_id ? SLAS_2025.out.session_id : SLAS_2025.out.run_name
            break
        default:
            error "Unknown event: ${params.event}. Supported events are 'fog_2025', 'slas_2025', 'ismb_bosc2024', 'biotechx_basel_2024' and 'ashg_2024'"
    }

    PUBLISH_REPORT(html_report, event, ticket_number)

    // Display help message
    if (params.help) {
        log.info """
        Usage:
        nextflow run seqeralabs/nf-raffle --event [event_name]

        Supported event names:
            - ismb_bosc2024
            - biotechx_basel_2024
            - ashg_2024
            - slas_2025

        For more information for an event, use the --help flag for that event.
        """
        System.exit(0)
    }

}