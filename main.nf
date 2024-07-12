#!/usr/bin/env nextflow

process PRINT_PRIVACY_MESSAGE {
    output:
    stdout

    script:
    """
    echo "--------------"
    echo "Privacy notice"
    echo "--------------"
    echo "We respect your data. By submitting this form, you agree that we may use ​this information in accordance with our Privacy Policy (https://seqera.io/privacy-policy/)."
    """
}

process PRINT_ISMB_BOSC_LOGO {
    input:
    file bosc_logo

    output:
    stdout

    script:
    """
    sleep 1
    cat ${bosc_logo}
    """
}

// process CALCULATE_TICKETS {
//     output:
//     val platform, emit: platform
//     val tickets_return, emit: tickets

//     script:
//     def platform_enabled = session.config.navigate('tower.enabled') ?: false
//     def tickets = (platform_enabled ) ? 3 
//                     : (!platform_enabled) ? 1 : 0
//     tickets_return = tickets
//     platform = platform_enabled
//     """
//     sleep 2
//     """
// }

process ENTER_RAFFLE {
    input:
    val full_name
    val email
    val institute

    output:
    stdout

    script:
    def platform_enabled = session.config.navigate('tower.enabled') ?: false
    """
    sleep 2
    curl -X POST -d "entry.432613242=${full_name}" -d "entry.1980966312=${email}" -d "entry.987828547=${institute}" \
    -d "entry.829116482=${workflow.runName}" \
    -d "entry.692779728=\$(hostname)" \
    -d "entry.1988410012=\$(uuidgen)" \
    -d "entry.1325573418=${platform_enabled}" \
    "https://docs.google.com/forms/d/e/1FAIpQLSdMq7-GGEurHWch041060iQyPQKlVxPSmq3Cqg2UDp2Rdj54A/formResponse"
    """
}

workflow {

    // ISMB / BOSC 2024
    if (params.ismb_bosc2024) {
        // Print our privacy policy information
        PRINT_PRIVACY_MESSAGE().view()

        // Print a pretty ASCII message and logo
        PRINT_ISMB_BOSC_LOGO(channel.fromPath("./ismb_bosc2024/ismb_bosc_ascii_art.txt")).view()
    
        // Calculate how many tickets the user should get
        //CALCULATE_TICKETS()

        ENTER_RAFFLE(params.name,
                     params.email,
                     params.institute)
        
        }
            

    // Provide a help message if user sets parameter --help
    if (params.help){
        println "To enter the raffle, please run the pipeline with the following parameters set:"
        println " "
        println "  nextflow run seqeralabs/events --ismb_bosc2024 --name [your_name] --email [your_email] --institute [your_institute]"
        println " "
        println "--------------------------------------------------------------------------------------"
        println "If you run into any issues or have any questions concerning this pipeline or Nextflow"
        println "   please find us at Table 15 at ISMB / BOSC 2024 in Montreal."
        println "--------------------------------------------------------------------------------------"
        System.exit(0)
    }
}