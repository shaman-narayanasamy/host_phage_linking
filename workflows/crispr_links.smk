import subprocess
import pandas as pd

## Define output directory
output_dir = os.path.join(config["outdir"]["root"], config["outdir"]["subdir"], "crispr_links")
tmp_dir = config["tmp_dir"]

## Define input files
hosts = None

# Read the phage table
phage_dbs = pd.read_table(config["phage_db_table"], sep="\t", comment = "#").set_index("ID", drop=False)

# 1. Detect and assign mode (host, spacer, repeat, flank)
mode = []

if "host_table" in config:
    hosts = pd.read_table(config["host_table"], sep="\t", comment="#").set_index("ID", drop=False)
    mode.append("host")

if "spacers_fasta" in config:
    mode.append("spacer")

if "repeats_fasta" in config:
    mode.append("repeat")

if "flanks_fasta" in config:
    mode.append("flank")

if not mode:
    raise ValueError("Provide at least one of: 'host_table', 'spacers_fasta', 'repeats_fasta', or 'flanks_fasta'.")

# Convert mode to set for easy matching
mode_set = set(mode)

# Check for invalid configurations
if "repeat" in mode_set and "host" not in mode_set:
    raise ValueError("Repeats require host genomes.")

if "flank" in mode_set and "host" not in mode_set:
    raise ValueError("Flanks require host genomes.")

workdir:
    output_dir

# Common rules
include:
    "../rules/makeblastdb_host_genomes.smk"

# 2. Conditionally include rules
## Host-only pipeline
if mode_set == {"host"}:
    include: "../rules/prepare_data.smk"
    #include: "../rules/spacepharer_prepare_db_split.smk"
    include: "../rules/spacepharer_prepare_db_phages.smk"
    include: "../rules/pilercr.smk"
    include: "../rules/minced.smk"
    include: "../rules/spacepharer_genomes.smk"
    include: "../rules/crisprcasfinder.smk"

## Spacer pipeline (independent of host presence)
if "spacer" in mode_set:
    #include: "../rules/spacepharer_prepare_db_spacers.smk"
    include: "../rules/spacepharer_prepare_db_phages.smk"
    #include: "../rules/spacepharer_predictmatch.smk"
    include: "../rules/spacepharer_spacers.smk"
    include: "../rules/makeblastdb_phage_genomes.smk"
    include: "../rules/blastn_spacers.smk"

## Repeats require host
if "repeat" in mode_set:
    include: "../rules/blastn_repeats.smk"

## Flanks require host
if "flank" in mode_set:
    include: "../rules/blastn_flanks.smk"

# 3. Dynamically define outputs based on mode
all_outputs = []

if mode_set == {"host"}:
    #all_outputs += expand(os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}"), phage_db_id=phage_dbs.index)
    all_outputs += expand("host_pilercr/{host_id}.out", host_id=hosts.index)
    all_outputs += expand("host_minced/{host_id}.txt", host_id=hosts.index)
    all_outputs += expand("spacepharer/{host_id}-x-{phage_db_id}/predictions.tsv", phage_db_id=phage_dbs.index, host_id=hosts.index)
    all_outputs += expand("host_crisprcasfinder/{host_id}/result.json", host_id=hosts.index)

if "spacer" in mode_set:
    all_outputs += expand("spacepharer/spacers-x-{phage_db_id}/predictions.tsv", phage_db_id=phage_dbs.index)
    all_outputs += expand("blast/results/spacers/{phage_db_id}_final_blast.tsv", phage_db_id=phage_dbs.index)

if "repeat" in mode_set:
    all_outputs += ["blast/results/repeats/final_blast.tsv"]

if "flank" in mode_set:
    all_outputs += ["blast/results/flanks/final_blast.tsv"]

#print(all_outputs)

rule crispr_links_all:
     input:
       all_outputs
     output: touch("crispr_links.done")
