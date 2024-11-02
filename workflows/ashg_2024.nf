#!/usr/bin/env nextflow

include { ENTER_RAFFLE_GENERAL } from '../modules/local/enter_raffle_general'
include { PRINT_PRIVACY_MESSAGE } from '../modules/local/print_privacy_message'

workflow ASHG_2024 {
    main:
    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()
    
    ENTER_RAFFLE_GENERAL(PRINT_PRIVACY_MESSAGE.out, params.email)

    emit:
    session_id =  ENTER_RAFFLE_GENERAL.out.session_id
    run_name   =  ENTER_RAFFLE_GENERAL.out.run_name  
}