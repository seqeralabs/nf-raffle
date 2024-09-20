#!/usr/bin/env nextflow

include { ENTER_RAFFLE_BIOTECHX } from '../modules/local/enter_raffle_biotechx'
include { PRINT_PRIVACY_MESSAGE } from '../modules/local/print_privacy_message'

workflow BIOTECHX_2024 {
    main:
    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()
    
    ENTER_RAFFLE_BIOTECHX(PRINT_PRIVACY_MESSAGE.out, params.email)

    emit:
    ticket_number =  ENTER_RAFFLE_BIOTECHX.out.ticket_number
}