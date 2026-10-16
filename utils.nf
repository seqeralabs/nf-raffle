nextflow.enable.types = true

include { validate } from 'plugin/nf-schema'
include { EventConfig } from './types'

// Parses an event config, validates it against assets/schema_event_config.json
// (fails the run with the schema errors) and returns it as an EventConfig.
def loadEventConfig(path: String) -> EventConfig {
    def config_file = file(path)
    if (!config_file.exists()) {
        error("Event config not found: ${config_file}")
    }
    def parsed = new groovy.json.JsonSlurper().parse(config_file)
    validate(parsed, "${moduleDir}/assets/schema_event_config.json")
    return parsed as EventConfig
}

// The typed `workflow` namespace has no accessor for the `tower` config scope,
// so read it from the session config. `-with-tower` and `nextflow auth login`
// both set tower.enabled there.
def towerConfig() -> Map<String,?> {
    def session_config = nextflow.Global.getSession().getConfig() as Map<String,?>
    return (session_config['tower'] ?: [:]) as Map<String,?>
}
