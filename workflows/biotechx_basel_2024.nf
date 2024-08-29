include { PRINT_PRIVACY_MESSAGE } from '../modules/local/print_privacy_message'
include { ENTER_RAFFLE_BIOTECHX } from '../modules/local/enter_raffle_biotechx'

workflow BIOTECHX_2024 {

    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()
    
    ENTER_RAFFLE_BIOTECHX(
        PRINT_PRIVACY_MESSAGE.out,
        params.email
    )
}