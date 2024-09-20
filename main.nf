#!/usr/bin/env nextflow

include { ISMB_BOSC_2024 } from './workflows/ismb_bosc_2024'
include { BIOTECHX_2024  } from './workflows/biotechx_basel_2024'
include { PUBLISH_REPORT } from './modules/local/publish_report'

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

            event = "ISMB/BOSC 2024"
            ticket_number = ISMB_BOSC_2024.out.ticket_number
            break

        case "biotechx_basel_2024":
            if (!params.email) {
                error "Please provide --email parameter to enter the raffle at BiotechX Basel 2024."
            }
            BIOTECHX_2024()
            event = "BiotechX BASEL 2024"
            ticket_number = BIOTECHX_2024.out.ticket_number

            break
        default:
            error "Unknown event: ${params.event}. Supported events are 'ismb_bosc2024' and 'biotechx_basel_2024'"
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

        For more information for an event, use the --help flag for that event.
        """
        System.exit(0)
    }

}