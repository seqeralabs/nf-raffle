// Validates every event_configs/*.json against assets/schema_event_config.json
// and loads it as an EventConfig. Never contacts a form.
//   nextflow run tests/validate_event_configs.nf

nextflow.enable.types = true

include { loadEventConfig } from '../utils'

workflow {
    def configs = files("${projectDir}/../event_configs/*.json")
    if (!configs) {
        error("No event configs found")
    }
    configs.each { config_file ->
        def config = loadEventConfig("${config_file}")
        println("OK ${config_file.baseName}: ${config.event_name} (${config.form_fields.size()} form fields)")
    }
}
