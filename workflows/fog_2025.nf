#!/usr/bin/env nextflow

include { FOG25                 } from '../modules/local/fog_2025'
include { PRINT_PRIVACY_MESSAGE } from '../modules/local/print_privacy_message'

workflow FOG25_WORKFLOW {
    main:
    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()
    
    FOG25(PRINT_PRIVACY_MESSAGE.out, params.email)

    emit:
    session_id =  FOG25.out.session_id
    run_name   =  FOG25.out.run_name  
}