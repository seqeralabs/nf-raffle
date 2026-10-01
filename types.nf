nextflow.enable.types = true

// Shared record type describing an event configuration loaded from
// event_configs/<event>.json. Optional fields (present in only some events)
// are declared nullable so every event config duck-types to EventConfig.
record EventConfig {
    event_name: String
    help: String
    destination_url: String
    form_fields: Map<String,String>
    required_fields: List<String>?
    winner_announcement: String?
}

// Participant-supplied raffle entry details. Only `email` is always required;
// the name/affiliation fields are optional here because each event decides
// which of them are mandatory via EventConfig.required_fields (validated in
// the entry workflow). Unset fields arrive as empty strings from params.
record Participant {
    email: String
    first_name: String?
    last_name: String?
    affiliation: String?
}
