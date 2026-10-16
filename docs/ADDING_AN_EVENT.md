# Adding a new event

Each event is one JSON file in [`event_configs/`](../event_configs/) that points the pipeline at a Google Form. [`scripts/new_event.py`](../scripts/new_event.py) generates that file from the form and updates the `--event` list, so you shouldn't need to edit JSON by hand.

## 1. Create the Google Form

Copying the previous event's form (⋮ → **Make a copy**) is the quickest way to get the right questions. Otherwise create one **Short answer** question per field below.

| Question title | Field | Make it Required? |
| --- | --- | --- |
| Email | `email` | Optional (the pipeline always sends it) |
| First name | `first_name` | Your choice |
| Last name | `last_name` | Your choice |
| Affiliation | `affiliation` | Your choice |
| run_name | `run_name` | Optional |
| uuid | `uuid` | Optional |
| seqera_platform_used | `platform_enabled` | Optional |
| hostname | `hostname` | **No** |
| user_name | `user_name` | **No** |
| workspace_id | `workspace_id` | **No** |
| platform_workflow_id | `platform_workflow_id` | **No** |

* `run_name`, `uuid` and `seqera_platform_used` (Platform monitoring on or off, which decides the bonus entries) are needed to run the draw. Include them.
* `hostname`, `user_name`, `workspace_id` and `platform_workflow_id` let you filter out demo runs by Seqera staff (for example, entries launched from the booth's Platform workspace). Include them unless you have a reason not to. They are often empty, so they must **not** be Required.
* Any question marked Required that the pipeline doesn't fill makes Google Forms silently drop the whole entry. curl still gets HTTP 200, so nothing tells you the entry was lost. The script refuses forms with that problem.
* Questions the pipeline doesn't know about are left blank, so they must be optional too.

## 2. Check the form settings

In **Settings**:

- [ ] **Responses → Collect email addresses: Do not collect.** The pipeline sends the email as a normal question. "Verified" or "Responder input" makes anonymous submissions fail.
- [ ] **Responses → Limit to 1 response: off**, and no sign-in requirement. The pipeline submits without a Google account.
- [ ] **Responder access** (Publish / Share → Responders): **Anyone with the link**, not restricted to your organization.
- [ ] The form is **published** and **accepting responses**.
- [ ] Optionally, link a response spreadsheet (**Responses → Link to Sheets**) to run the draw.

## 3. Generate the config

Preferred: a pre-filled link, which maps entry IDs exactly. In the form editor choose ⋮ → **Get pre-filled link**, type each question's field name from the table above as its answer (`email`, `first_name`, …, `platform_enabled`), then click **Get link** → **Copy link**.

```bash
scripts/new_event.py add \
  --event ashg_2027 \
  --name "ASHG 2027" \
  --url 'https://docs.google.com/forms/d/e/<FORM_ID>/viewform?usp=pp_url&entry.123=email&entry.456=first_name&...' \
  --winner-announcement "3pm EDT on October 23rd, 2027" \
  --set-default
```

You can also pass the plain public link (`.../viewform`). The script then matches questions to fields by their title, using the titles in the table above and common variants like "Organization" or "Company".

Either way, the script reads the public form page (it never submits anything) to find Required questions. It then:

- writes `event_configs/<event>.json` with `destination_url`, `form_fields`, and `required_fields` (the participant questions marked Required);
- adds the event to the `--event` enum in `nextflow_schema.json` and to the README event table;
- with `--set-default`, makes it the default event in `main.nf`, `nextflow_schema.json` and the README.

Other options: `--required first_name,last_name,affiliation` sets `required_fields` by hand, for example if the form page can't be fetched. `--html saved_page.html` reads a saved copy of the form page instead of fetching it.

## 4. Finish up

- [ ] Review the generated JSON. Every question you created should appear in `form_fields`.
- [ ] If you changed the default event, update the default named in [`docs/INSTRUCTIONS.md`](INSTRUCTIONS.md), [`docs/index.html`](index.html) (the example commands) and [`CLAUDE.md`](../CLAUDE.md).
- [ ] Move configs for events that are over to [`event_configs/archive/`](../event_configs/archive/) and run `scripts/new_event.py sync`.
- [ ] Open a PR. CI validates the config against [`assets/schema_event_config.json`](../assets/schema_event_config.json) and checks that the event list is in sync. CI never submits to your form.
- [ ] After merging, make one real entry yourself and confirm it appears in the form's responses. This is the only check that the form settings are right.

## Config reference

`event_configs/<event>.json` is validated against [`assets/schema_event_config.json`](../assets/schema_event_config.json) every time the pipeline runs.

| Key | Required | Description |
| --- | --- | --- |
| `event_name` | yes | Display name, shown on the ticket |
| `help` | yes | One-line description |
| `destination_url` | yes | The form's `.../formResponse` URL |
| `form_fields` | yes | Field → `entry.<id>` map; must include `email`. Fields without a mapping are not sent |
| `required_fields` | no | Any of `email`, `first_name`, `last_name`, `affiliation`. The run fails if one is missing on the command line. Must include every participant question marked Required in the form |
| `winner_announcement` | no | When the winner is announced; printed in the privacy notice and on the ticket |
