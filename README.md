# 🎟️ nf-raffle

This repository contains code for the nf-raffle pipeline, which is used for managing raffles at events attended or sponsored by Seqera.

## Description

nf-raffle is a Nextflow pipeline designed to streamline the process of entering raffles at various events. It provides a simple and efficient way to collect participant information and enter them into event-specific raffles.

## Supported Events

Currently, the pipeline supports the following events:

- ISMB/BOSC 2024      [--event ismb_bosc2024]
- BiotechX Basel 2024 [--event biotechx_basel_2024]
- ASHG 2024           [--event ashg_2024]
- SLAS 2025           [--event slas_2025]
- FOG 2025            [--event fog_2025]
- ISMB 2025           [--event ismb_2025]

## How to Run

### Overview

The nf-raffle pipeline guides you through an interactive raffle entry process where you'll provide your contact information and be entered into the event raffle. The pipeline uses Nextflow and integrates with Seqera Platform for enhanced functionality.

If you are already familiar with Nextflow, you can enter the raffle the following way:

1. Ensure you have a Seqera Platform access token set as `TOWER_ACCESS_TOKEN` in your environment.
2. Run the Nextflow pipeline `seqeralabs/nf-raffle`
3. (Optional) Add `--event [event_name]` to specify one of the supported events (defaults to `ismb_2025` if not specified).

Below are detailed instructions for new users.

### Step 1: Install Nextflow

First, ensure you have Java 11 or later installed, then install Nextflow:

```bash
# Install Nextflow
curl -s https://get.nextflow.io | bash

# Make it executable and move to your PATH
chmod +x nextflow
sudo mv nextflow /usr/local/bin/
```

Verify the installation:

```bash
nextflow -version
```

You should see something like this:

```console
>  nextflow -version                                                      

      N E X T F L O W
      version 25.04.6 build 5954
      created 01-07-2025 11:27 UTC (12:27 BST)
      cite doi:10.1038/nbt.3820
      http://nextflow.io
```

### Step 2: Create a Seqera Platform Account

1. Visit [https://cloud.seqera.io](https://cloud.seqera.io)
2. Sign up for a free account or sign in with your existing credentials
3. Complete the account verification process

### Step 3: Generate an Access Token

1. Navigate to **Your profile** → **Access tokens** in the Seqera Platform
2. Click **New token**
3. Provide a name for your token (e.g., "nf-raffle-token")
4. Click **Create** and copy the generated token

### Step 4: Set Environment Variable

Set your access token as an environment variable:

```bash
export TOWER_ACCESS_TOKEN=your_token_here
```

### Step 5: Run the Pipeline

```bash
nextflow run seqeralabs/nf-raffle -with-tower
```

Add `--event [event_name]` to specify one of the supported events (defaults to `ismb_2025` if not specified).
