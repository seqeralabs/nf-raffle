process PUBLISH_REPORT {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path html_report
    val event
    val ticket_number

    output:
    path "raffle_ticket.html"

    script:
    """
    cp $html_report raffle_ticket.html
    sed -i -e 's/EVENT/${event}/g' raffle_ticket.html
    sed -i -e 's/TICKET_NUMBER/${ticket_number}/g' raffle_ticket.html
    """
}
