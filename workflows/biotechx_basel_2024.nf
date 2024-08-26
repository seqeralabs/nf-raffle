include { PRINT_PRIVACY_MESSAGE } from '../modules/local/messaging.nf'
include { ENTER_RAFFLE_BIOTECHX          } from '../modules/local/raffle.nf'

workflow BIOTECHX_2024 {

    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()
    
    ENTER_RAFFLE_BIOTECHX(
        PRINT_ISMB_BOSC_LOGO.out,
        params.name,
        params.email,
        params.institute)
}