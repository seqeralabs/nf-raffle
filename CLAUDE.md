# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

nf-raffle is a Nextflow pipeline for managing event raffles at Seqera-sponsored conferences. Participants enter by providing their email (and, for some events, name and affiliation), and the pipeline submits entries to Google Forms configured per-event.

Requires Nextflow 26.10+. All scripts use static typing (`nextflow.enable.types = true`); `nextflow lint .` must stay clean.

## Running the Pipeline

```bash
# Default event (ashg_2026, which requires name and affiliation)
nextflow run main.nf --email user@example.com --first_name A --last_name B --affiliation C

# Specify event
nextflow run main.nf --email user@example.com --event fog_2026

# With Docker profile
nextflow run main.nf --email user@example.com ... -profile docker

# With Seqera Platform monitoring (gives extra raffle entries)
nextflow run main.nf --email user@example.com ... -with-tower

# Local test against a mock form. Never test against a real event form.
python3 tests/mock_form_server.py --port 8765 --log requests.jsonl &
nextflow run . -profile test
```

Required environment variable for Seqera Platform: `TOWER_ACCESS_TOKEN`

## Architecture

### Pipeline Flow (main.nf)
1. `--help` prints nf-schema help; `validateParameters()` checks params against `nextflow_schema.json` (unknown `--event` values fail here)
2. `loadEventConfig()` (`utils.nf`) parses `event_configs/<event>.json`, validates it against `assets/schema_event_config.json` with nf-schema `validate()`, and casts it to the `EventConfig` record (`types.nf`)
3. `required_fields` check, then **PRINT_PRIVACY_MESSAGE** (exec-only, no container)
4. **ENTER_RAFFLE** - POSTs the entry to the Google Form with curl
5. **PUBLISH_REPORT** - generates the HTML raffle ticket from a template; published via the `output {}` block

### Key Components

- `types.nf` - `EventConfig` and `Participant` records
- `utils.nf` - `loadEventConfig()` and `towerConfig()`. The typed `workflow` namespace has no accessor for the `tower` config scope, so `towerConfig()` reads it from `nextflow.Global.session.config` (this is the only internal API used). `platform_enabled` = `tower.enabled`, which `-with-tower` and `nextflow auth login` both set.
- `event_configs/*.json` - one file per *current* event; the set of files must equal the `--event` enum. Past events live in `event_configs/archive/` and are not selectable.
- `assets/schema_event_config.json` - JSON Schema for event configs
- `assets/ticket_template.html` - template with EVENT, TICKET_NUMBER and WINNER_ANNOUNCEMENT placeholders. `sed` replaces these words anywhere in the file, so don't use them elsewhere in it.
- `assets/seqera-*.svg` - official logos copied unmodified from https://brand.seqera.io/img/; never edit or recreate them. `docs/index.html`, the ticket template and the README use these files, colours from the brand palette (https://brand.seqera.io/color.html; Brand Green `#31C9AC` is never a text colour), and Degular/Inter/JetBrains Mono fonts.
- `modules/local/enter_raffle` - builds the curl command from `form_fields`
- `modules/local/print_privacy_message` - pure Groovy exec block
- `modules/local/publish_report` - sed-based HTML template substitution
- `tower.yml` - shows the generated ticket as a report in Seqera Platform
- `scripts/new_event.py` - generates event configs and syncs the enum/README (see below)
- `tests/` - mock form server, test event config, submission assertions, event config validation script

### Form fields

`ENTER_RAFFLE` sends a field only if the event's `form_fields` maps it to an `entry.<id>` and its value is non-empty. Unmapped fields are skipped, so each event's form decides what it collects.

| Field | Source |
|-------|--------|
| `email`, `first_name`, `last_name`, `affiliation` | CLI params |
| `run_name` | `workflow.runName` (also the ticket number) |
| `uuid` | `uuidgen` (falls back to `/proc/sys/kernel/random/uuid`) |
| `platform_enabled` | `tower.enabled` |
| `hostname` | `hostname` in the task |
| `user_name` | `workflow.userName` |
| `workspace_id` | `TOWER_WORKSPACE_ID` env var (set when running on Platform) |
| `platform_workflow_id` | `TOWER_WORKFLOW_ID` env var (set when launched FROM Platform) |

The last four distinguish demo runs by Seqera staff from participant entries:
- **Local run**: `hostname`, `user_name` populated
- **Run with `-with-tower`**: plus `workspace_id` if `TOWER_WORKSPACE_ID` is set in the environment
- **Run FROM Seqera Platform**: all populated

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--email` | (required) | Participant email |
| `--event` | `ashg_2026` | Event identifier; must be in the `nextflow_schema.json` enum |
| `--affiliation` | `""` | Company/institution (organization) |
| `--first_name` | `""` | First name |
| `--last_name` | `""` | Last name |
| `--outdir` | `results` | Output directory |
| `--ticket_number_emit_session_id` | `false` | Use session ID instead of run name (hidden) |
| `--event_config` | `""` | Test only: path to an event config replacing `event_configs/<event>.json` (hidden; used by the `test` profile) |

Field requiredness is config-driven via a per-event `required_fields` array. `main.nf` errors if any listed participant-supplied field is empty.

Important: any question marked **Required** in an event's Google Form must be listed in `required_fields` (or always be sent by the pipeline: `run_name`, `uuid`, `platform_enabled`, `hostname`). Google Forms rejects the entire submission if a Required field is empty in the POST, and the failure is silent (curl still returns HTTP 200).

## Adding a New Event

Follow `docs/ADDING_AN_EVENT.md`. In short:

```bash
scripts/new_event.py add --event <id> --name "<Display Name>" --url '<pre-filled or viewform link>' [--winner-announcement "..."] [--set-default]
```

This writes `event_configs/<id>.json` and runs `scripts/new_event.py sync`, which regenerates the `--event` enum/default in `nextflow_schema.json` and `main.nf` and the README event table. CI runs `sync --check`. When changing the default, also update the default named in `docs/INSTRUCTIONS.md`, `docs/index.html` and this file.

## CI

`.github/workflows/run-pipeline.yml` runs `nextflow lint .`, `scripts/new_event.py sync --check`, `tests/validate_event_configs.nf`, and pipeline runs with `-profile test` against `tests/mock_form_server.py` (with and without `-with-tower` pointed at the mock). It also checks that an invalid `--event` and a missing required field fail before submitting. CI must never hit a real form.
