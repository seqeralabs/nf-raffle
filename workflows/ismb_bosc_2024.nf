#!/usr/bin/env nextflow

include { CONGRATULATIONS        } from '../modules/local/congratulations'
include { ENTER_RAFFLE_ISMB_BOSC } from '../modules/local/enter_raffle_ismb_bosc'
include { PRINT_ISMB_BOSC_LOGO   } from '../modules/local/print_ismb_bosc_logo'
include { PRINT_PRIVACY_MESSAGE  } from '../modules/local/print_privacy_message'

workflow ISMB_BOSC_2024 {

    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()

    // Print a pretty ASCII message and logo
    ascii = Channel.fromPath("${baseDir}/ismb_bosc2024/ismb_bosc_ascii_art.txt")
    PRINT_ISMB_BOSC_LOGO(ascii, PRINT_PRIVACY_MESSAGE.out)

    ENTER_RAFFLE_ISMB_BOSC(
        PRINT_ISMB_BOSC_LOGO.out,
        params.name,
        params.email,
        params.institute)
    
    congrats = Channel.fromPath("${baseDir}/ismb_bosc2024/congratulations.txt")
    CONGRATULATIONS(congrats,ENTER_RAFFLE_ISMB_BOSC.out)
    
}