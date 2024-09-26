#!/usr/bin/env nextflow

include { CONGRATULATIONS        } from '../modules/local/congratulations'
include { ENTER_RAFFLE_ISMB_BOSC } from '../modules/local/enter_raffle_ismb_bosc'
include { PRINT_ASCII_LOGO       } from '../modules/local/print_ascii_logo'
include { PRINT_PRIVACY_MESSAGE  } from '../modules/local/print_privacy_message'

workflow ISMB_BOSC_2024 {
    take:
    ascii
    congrats

    main:
    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()

    // Print a pretty ASCII message and logo
    PRINT_ASCII_LOGO(ascii, PRINT_PRIVACY_MESSAGE.out)

    ENTER_RAFFLE_ISMB_BOSC(
        PRINT_ASCII_LOGO.out,
        params.name,
        params.email,
        params.institute)
    
    CONGRATULATIONS(congrats, ENTER_RAFFLE_ISMB_BOSC.out.session_id)

    emit:
    session_id =  ENTER_RAFFLE_ISMB_BOSC.out.session_id
    run_name   =  ENTER_RAFFLE_ISMB_BOSC.out.run_name  
}