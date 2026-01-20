process PRINT_PRIVACY_MESSAGE {
    label 'process_single'

    input:
    val config

    output:
    val true

    exec:
    def winner_text = config.winner_announcement ? "\nWinner will be announced at ${config.winner_announcement}.\n" : ""
    println(
        """\
--------------
Privacy notice
--------------
We respect your data. By submitting this form, you agree that we may use ​this
information in accordance with our Privacy Policy (https://seqera.io/privacy-policy/).
${winner_text}""".stripIndent()
    )
}
