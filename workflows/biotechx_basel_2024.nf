#!/usr/bin/env nextflow

include { PRINT_PRIVACY_MESSAGE } from '../modules/local/print_privacy_message'
include { ENTER_RAFFLE_BIOTECHX } from '../modules/local/enter_raffle_biotechx'

process PUBLISH_REPORT {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path html_report

    output:
    path "raffle_ticket.html"

    script:
    """
    cp $html_report raffle_ticket.html
    """
}

workflow BIOTECHX_2024 {

    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()
    
    ENTER_RAFFLE_BIOTECHX(
        PRINT_PRIVACY_MESSAGE.out,
        params.email
    )

    // Publish the HTML report
    html_report = file("$projectDir/ticket_template.html")
    PUBLISH_REPORT(html_report)
}