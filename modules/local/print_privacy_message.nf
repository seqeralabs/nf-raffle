process PRINT_PRIVACY_MESSAGE {
    label 'process_single'

    output:
    val true

    exec:
    println """\
--------------
Privacy notice
--------------
We respect your data. By submitting this form, you agree that we may use ​this information in accordance with our Privacy Policy (https://seqera.io/privacy-policy/).
""".stripIndent()
}