process PUBLISH_REPORT {
    tag "${event}: ${ticket_number}"
    publishDir "${params.outdir}", mode: 'copy'
    container 'community.wave.seqera.io/library/sed_coreutils_procps-ng:749edc0a4a6c3ef9'
    conda "sed coreutils procps-ng"

    input:
    path html_report
    val event
    val ticket_number

    output:
    path "raffle_ticket.html"

    script:
    """
    cp ${html_report} raffle_ticket.html
    sed -i -e 's/EVENT/${event}/g' raffle_ticket.html
    sed -i -e 's/TICKET_NUMBER/${ticket_number}/g' raffle_ticket.html
    """
}
