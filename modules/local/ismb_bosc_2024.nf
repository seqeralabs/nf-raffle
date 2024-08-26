process PRINT_ISMB_BOSC_LOGO {
    debug true
    input: 
    path bosc_logo
    val next
    
    output:
    val true

    script:
    "cat ${bosc_logo}"
}