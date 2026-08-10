# Host-phage linking

Reusable Snakemake workflows for linking bacterial or archaeal hosts to phage
genomes using complementary sequence-based evidence. The repository retains
CRISPR spacer matching, nucleotide identity, and optional prediction workflows
behind a shared host/phage manifest interface.

## Status

The workflow is under active hardening. Its rules and environment definitions
are reusable, while the checked-in `config/config.yml` and SLURM settings are
site-specific examples that must be localized before execution. Stable output
contracts are tracked in the repository issue tracker.

For the PRJEB79569 phage-UV project, this repository produces optional
host-phage evidence for later ecological integration. It is not the manuscript
analysis workspace.

## Inputs

The main workflow expects tab-separated manifests with an `ID` column and a
path column for:

- host genomes or MAGs;
- phage or vOTU FASTA collections;
- optional host taxon groupings.

Database paths, temporary storage, output roots, and tool-specific options are
configured in YAML. Keep machine-specific configurations in ignored local
files rather than committing credentials or personal paths.

## Workflow entrypoints

- `workflows/master.smk`: combined host-phage evidence workflow;
- `workflows/crispr_links.smk`: CRISPR spacer evidence;
- `workflows/crisprcasfinder.smk`: optional CRISPR-CasFinder path;
- `workflows/identity_links.smk`: nucleotide-identity evidence.

Rules live under `rules/`; software environments live under `envs/`.

## Running on SLURM

Review and localize `config/config.yml` and `config/ibex_cluster_config.yml`,
then start with a dry run:

```sh
bash launchers/sbatch.sh --dry-run
```

Run the workflow only after the dry run resolves the expected inputs:

```sh
bash launchers/sbatch.sh
```

`launchers/sbatch_crisprcasfinder.sh` is retained for the optional
CRISPR-CasFinder branch. Launchers are operational entrypoints, not generated
job files; scheduler logs and workflow state belong outside version control.

## Repository layout

```text
config/      workflow and scheduler configuration
envs/        reproducible software environment definitions
launchers/   SLURM submission entrypoints
rules/       method-specific Snakemake rules
scripts/     data preparation and reporting utilities
workflows/   top-level Snakemake workflows
```

Generated databases, workflow outputs, rendered reports, and logs should be
written to project storage rather than committed to this repository.
