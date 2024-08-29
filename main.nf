#!/usr/bin/env nextflow

include { ISMB_BOSC_2024 } from './workflows/ismb_bosc_2024'
include { BIOTECHX_2024 } from './workflows/biotechx_basel_2024'

workflow {
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
            ISMB_BOSC_2024()
            break
        case "biotechx_basel_2024":
            if (!params.email) {
                error "Please provide --email parameter to enter the raffle at BiotechX Basel 2024."
            }
            BIOTECHX_2024()
            break
        default:
            error "Unknown event: ${params.event}. Supported events are 'ismb_bosc2024' and 'biotechx'"
    }
}

// Display help message
if (params.help) {
    log.info """
    Usage:
      nextflow run seqeralabs/events --event [event_name]

    Supported events:
      - ismb_bosc2024
      - biotechx_basel_2024

    For more information for an event, use the --help flag for that event.
    """
    exit 0
}