# 🎟️ nf-raffle: Nextflow CLI Instructions

Welcome to the nf-raffle pipeline! This guide will walk you through entering event raffles using the Nextflow command line interface.

## Prerequisites

Before you begin, ensure you have:

- [**Nextflow installed** (version 25.04.7 or later)](https://www.nextflow.io/docs/latest/install.html#installation)
- **Internet connection** for downloading the pipeline and submitting entries
- **Valid email address** for raffle entry

## Quick Start

The simplest way to enter a raffle is to type this into your terminal:

```bash
nextflow run seqeralabs/nf-raffle --email your.email@example.com
```

This will enter you into the default event (biotechx 2025).

## Command Structure

```bash
nextflow run seqeralabs/nf-raffle --email EMAIL --event EVENT
```

## What Happens When You Run

1. **Raffle Entry**: Your information is submitted to the event's raffle system
2. **Ticket Generation**: A personalized raffle ticket is generated
3. **Results**: Your ticket is saved in the output directory (`results/` by default)

## Output Files

After successful execution, you'll find:

- `results/raffle_ticket.html` - Your personalized raffle ticket
- Various Nextflow work directories and logs

## Seqera Platform Integration

Seqera Platform allows you to run Nextflow pipelines on your own infrastructure, providing a user-friendly dashboard, real-time monitoring, and comprehensive logging. It is free to try!

You may earn additional points by connecting your run to Seqera Platform.

Go to [https://cloud.seqera.io](https://cloud.seqera.io) and make an account with the same email address you will use to run the pipeline. Once you have done so, run the pipeline using the additional flag `-with-tower`.

1. Create an account on Seqera Platform at <https://cloud.seqera.io>
2. Create a personal access token and save it somewhere safe or set it to the environment variable `TOWER_ACCESS_TOKEN`
3. Launch the pipeline with the additional flag `-with-tower` or using the configuration:

```nextflow
// Your tower.config or nextflow.config should include:
tower {
    enabled = true
    accessToken = 'YOUR_PERSONAL_ACCESS_TOKEN_HERE'
}
```

See further instructions [here](https://docs.seqera.io/platform-cloud/getting-started/deployment-options#nextflow--with-tower).

## Privacy Notice

We respect your data. By participating in the raffle, you agree that we may use ​this
information in accordance with our Privacy Policy (<https://seqera.io/privacy-policy/>)

## Support

For issues or questions:

- Check the [nf-raffle repository](https://github.com/seqeralabs/nf-raffle)
- Contact the event organizers
- Reach out to the Seqera team

---

**Happy raffling! 🎊**
