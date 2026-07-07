process PUBLISH_REPORT {
    tag "${event}: ${ticket_number}"
    publishDir "${params.outdir}", mode: 'copy'
    container 'community.wave.seqera.io/library/sed_coreutils_procps-ng:749edc0a4a6c3ef9'
    conda "${moduleDir}/environment.yml"

    input:
    path html_report
    val event
    val ticket_number
    val winner_announcement

    output:
    path "raffle_ticket.html"

    script:
    def winner_text = winner_announcement ? "Winner announced ${winner_announcement}" : ""
    """
    cp ${html_report} raffle_ticket.html
    sed -i -e 's|EVENT|${event}|g' raffle_ticket.html
    sed -i -e 's|TICKET_NUMBER|${ticket_number}|g' raffle_ticket.html
    sed -i -e 's|WINNER_ANNOUNCEMENT|${winner_text}|g' raffle_ticket.html
    """
}
