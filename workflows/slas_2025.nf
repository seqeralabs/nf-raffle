include { PRINT_PRIVACY_MESSAGE } from '../modules/local/print_privacy_message'
include { SLAS25                } from '../modules/local/slas_2025'

workflow SLAS_2025 {
    main:
    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()
    
    SLAS25(PRINT_PRIVACY_MESSAGE.out, params.email)

    emit:
    session_id =  SLAS25.out.session_id
    run_name   =  SLAS25.out.run_name  
}