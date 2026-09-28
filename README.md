# Host-phage linking

Snakemake workflows for linking bacterial and archaeal genomes to viral
sequences using CRISPR spacers and nucleotide identity.

## Inputs

Host and viral genome manifests are tab-separated tables with an `ID` column
and a path column. Optional host taxon groupings can be supplied separately.
Database locations, temporary storage and output paths are set in YAML.

## Workflows

| Source | Task |
| --- | --- |
| `workflows/master.smk` | Combined evidence workflow |
| `workflows/crispr_links.smk` | CRISPR spacer matching |
| `workflows/identity_links.smk` | Nucleotide-identity links |
| `workflows/crisprcasfinder.smk` | Optional CRISPR-CasFinder workflow |

Rules are in `rules/`, software environments in `envs/`, and submission
scripts in `launchers/`. Update `config/config.yml` and
`config/ibex_cluster_config.yml` for your system before running:

```sh
bash launchers/sbatch.sh --dry-run
```

When the dry run resolves the expected inputs, submit with
`bash launchers/sbatch.sh`. The optional CRISPR-CasFinder branch has a separate
launcher, `launchers/sbatch_crisprcasfinder.sh`.

## PRJEB79569 analysis

Host-phage evidence is integrated with ecological and expression analyses in
[phage_uv_ecology_analysis](https://github.com/shaman-narayanasamy/phage_uv_ecology_analysis).
Raw data: https://www.ebi.ac.uk/ena/browser/view/PRJEB79569.
Generated databases, results and scheduler logs belong in project storage.

The existing MIT licence is retained in `LICENSE`.
