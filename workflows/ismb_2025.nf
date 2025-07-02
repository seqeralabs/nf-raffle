include { PRINT_PRIVACY_MESSAGE }   from '../modules/local/print_privacy_message'
include { ISMB25                }   from '../modules/local/ismb_2025'

workflow ISMB_2025 {
    main:
    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()
    
    ISMB25(PRINT_PRIVACY_MESSAGE.out, params.email)

    emit:
    session_id =  ISMB25.out.session_id
    run_name   =  ISMB25.out.run_name  
}