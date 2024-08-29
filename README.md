# 🎟️ nf-raffle

This repository contains code for the nf-raffle pipeline, which is used for managing raffles at events attended or sponsored by Seqera.

## Description

nf-raffle is a Nextflow pipeline designed to streamline the process of entering raffles at various events. It provides a simple and efficient way to collect participant information and enter them into event-specific raffles.

## Supported Events

Currently, the pipeline supports the following events:

- ISMB/BOSC 2024      [--event ismb_bosc2024]
- BiotechX Basel 2024 [--event biotechx_basel_2024]

## How to Run

To run the nf-raffle pipeline, use the following command or launch the pipeline from Seqera Platform:

```bash
nextflow run seqeralabs/nf-raffle --event [event_name]
```

Replace `[event_name]` with the name of the event you want to enter.