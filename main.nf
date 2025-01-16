#!/usr/bin/env nextflow

include { ISMB_BOSC_2024 } from './workflows/ismb_bosc_2024'
include { BIOTECHX_2024  } from './workflows/biotechx_basel_2024'
include { ASHG_2024 }      from './workflows/ashg_2024'
include { PUBLISH_REPORT } from './modules/local/publish_report'
include { validateParameters; paramsSummaryLog } from 'plugin/nf-schema'

validateParameters()

workflow {
    main:
    // Print parameter summary
    log.info paramsSummaryLog(workflow)
    
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
