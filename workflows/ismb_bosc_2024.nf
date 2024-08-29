include { PRINT_PRIVACY_MESSAGE } from '../modules/local/print_privacy_message'
include { CONGRATULATIONS } from '../modules/local/congratulations'
include { PRINT_ISMB_BOSC_LOGO } from '../modules/local/print_ismb_bosc_logo'
include { ENTER_RAFFLE_ISMB_BOSC } from '../modules/local/enter_raffle_ismb_bosc'

workflow ISMB_BOSC_2024 {

    // Print our privacy policy information
    PRINT_PRIVACY_MESSAGE()

    // Print a pretty ASCII message and logo
    ascii = Channel.fromPath("${baseDir}/ismb_bosc2024/ismb_bosc_ascii_art.txt")
    PRINT_ISMB_BOSC_LOGO(ascii, PRINT_PRIVACY_MESSAGE.out)

    ENTER_RAFFLE_ISMB_BOSC(
        PRINT_ISMB_BOSC_LOGO.out,
        params.name,
        params.email,
        params.institute)
    
    congrats = Channel.fromPath("${baseDir}/ismb_bosc2024/congratulations.txt")
    CONGRATULATIONS(congrats,ENTER_RAFFLE_ISMB_BOSC.out)
    

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