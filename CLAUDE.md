# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

nf-raffle is a Nextflow pipeline for managing event raffles at Seqera-sponsored conferences. Participants enter by providing their email, and the pipeline submits entries to Google Forms configured per-event.

## Running the Pipeline

```bash
# Basic run (defaults to ashg_2025 event)
nextflow run main.nf --email user@example.com

# Specify event
nextflow run main.nf --email user@example.com --event slas_2025

# With Docker profile
nextflow run main.nf --email user@example.com -profile docker

# With Seqera Platform monitoring (gives extra raffle entries)
nextflow run main.nf --email user@example.com -with-tower
```

Required environment variable for Seqera Platform: `TOWER_ACCESS_TOKEN`

## Architecture

### Pipeline Flow (main.nf)
1. **PRINT_PRIVACY_MESSAGE** - Displays privacy notice (exec-only, no container)
2. **ENTER_RAFFLE** - Submits email to Google Form via curl POST request
3. **PUBLISH_REPORT** - Generates HTML raffle ticket from template

### Key Components

**Event Configs** (`event_configs/*.json`): JSON files defining per-event settings:
- `event_name`: Display name
- `destination_url`: Google Form submission URL
- `form_fields`: Mapping of data fields to Google Form entry IDs

**Modules** (`modules/local/`):
- `enter_raffle.nf` - Core logic; builds curl command from event config
- `print_privacy_message.nf` - Pure Groovy exec block (no container needed)
- `publish_report.nf` - sed-based HTML template substitution
- `print_ascii_logo.nf` and `congratulations.nf` - Currently unused

**Assets** (`assets/`):
- `ticket_template.html` - Template with EVENT and TICKET_NUMBER placeholders

**tower.yml**: Configures Seqera Platform to display the generated ticket as a report.

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--email` | (required) | Participant email |
| `--event` | `ashg_2025` | Event identifier |
| `--outdir` | `results` | Output directory |
| `--ticket_number_emit_session_id` | `false` | Use session ID instead of run name |

## Adding a New Event

1. Create `event_configs/<event_name>.json` with:
   - `event_name`: Human-readable name
   - `destination_url`: Google Form formResponse URL
   - `form_fields`: Map field names (`email`, `run_name`, `uuid`, `platform_enabled`) to form entry IDs
2. Update README.md to document the new `--event` option
