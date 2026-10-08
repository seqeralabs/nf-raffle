nextflow.enable.types = true

// Optional fields are nullable so every event config duck-types to EventConfig.
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
