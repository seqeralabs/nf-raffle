process PRINT_ISMB_BOSC_LOGO {
    tag "$bosc_logo"
    label 'process_single'

    input:
    path bosc_logo
    val next

    output:
    val true

    script:
    """
    cat ${bosc_logo}
    """
}