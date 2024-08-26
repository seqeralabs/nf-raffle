process PRINT_PRIVACY_MESSAGE {
    debug true
    
    output:
    val true

    script:
    """
    echo "--------------"
    echo "Privacy notice"
    echo "--------------"
    echo "We respect your data. By submitting this form, you agree that we may use ​this information in accordance with our Privacy Policy (https://seqera.io/privacy-policy/)."
    """
}

process CONGRATULATIONS {
    debug true

    input:
    path congrats
    val next

    script:
    """
    cat ${congrats}
    """
}
