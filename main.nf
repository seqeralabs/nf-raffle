#!/usr/bin/env nextflow

include { ISMB_BOSC_2024 } from './workflows/ismb_bosc_2024'
include { BIOTECHX_2024  } from './workflows/biotechx_basel_2024'
include { ASHG_2024 }      from './workflows/ashg_2024'
include { PUBLISH_REPORT } from './modules/local/publish_report'

// Display help message if requested
if (params.help) {
    log.info """
    Usage:
    nextflow run seqeralabs/nf-raffle --event [event_name]

    Supported event names:
        - ismb_bosc2024
        - biotechx_basel_2024
        - ashg_2024

    For more information for an event, use the --help flag for that event.
    """
    exit 0
}

workflow {
    main:
    // Input channels
    ascii       = Channel.fromPath("${projectDir}/assets/ismb_bosc2024/ismb_bosc_ascii_art.txt")
    congrats    = Channel.fromPath("${projectDir}/assets/congratulations.txt")
    html_report = Channel.fromPath("${projectDir}/assets/ticket_template.html")

    // Input validation
    if (!params.event) {
        error "Please specify an event using --event parameter"
    }

    // Event selection and processing
    def (event, ticket_number) = processEvent(params.event, ascii, congrats)

    // Generate report
    PUBLISH_REPORT(html_report, event, ticket_number)
}

def processEvent(eventName, ascii, congrats) {
    switch(eventName) {
        case 'ismb_bosc2024':
            validateIsmbParams()
            ISMB_BOSC_2024(ascii, congrats)
            return [
                "ISMB\\/BOSC 2024",
                params.ticket_number_emit_session_id ? ISMB_BOSC_2024.out.session_id : ISMB_BOSC_2024.out.run_name
            ]
            
        case 'biotechx_basel_2024':
            validateEmailParam("BiotechX Basel 2024")
            BIOTECHX_2024()
            return [
                "BiotechX BASEL 2024",
                params.ticket_number_emit_session_id ? BIOTECHX_2024.out.session_id : BIOTECHX_2024.out.run_name
            ]
            
        case 'ashg_2024':
            validateEmailParam("ASHG 2024")
            ASHG_2024()
            return [
                "ASHG 2024", 
                params.ticket_number_emit_session_id ? ASHG_2024.out.session_id : ASHG_2024.out.run_name
            ]
            
        default:
            error "Unknown event: ${eventName}. Supported events are 'ismb_bosc2024', 'biotechx_basel_2024' and 'ashg_2024'"
    }
}

def validateIsmbParams() {
    if (!params.name || !params.email || !params.institute) {
        error "Please provide --name, --email, and --institute parameters for ISMB/BOSC 2024"
    }
}

def validateEmailParam(eventName) {
    if (!params.email) {
        error "Please provide --email parameter to enter the raffle at ${eventName}"
    }
}