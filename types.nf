nextflow.enable.types = true

// Mirrors assets/schema_event_config.json, which main.nf validates each config
// against before casting it to this record. Optional fields are nullable.
record EventConfig {
    event_name: String
    help: String
    destination_url: String
    form_fields: Map<String,String>
    required_fields: List<String>?
    winner_announcement: String?
}

// Fields are optional here; EventConfig.required_fields determines which are mandatory per-event.
record Participant {
    email: String
    first_name: String?
    last_name: String?
    affiliation: String?
}
