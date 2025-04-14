import subprocess
import pandas as pd

## Define output directory
#output_dir = config["output_dir"]

## Define input files


hosts = None

# Read the phage table

phage_dbs = pd.read_table(config["phage_db_table"], sep="\t", comment = "#").set_index("ID", drop=False)

# Conditionally load host genomes or spacers
#if "host_table" in config:
    # Read the host genome table (individually listed)
    hosts = pd.read_table(config["host_table"], sep="\t", comment = "#").set_index("ID", drop=False)
#    mode = "host"
#elif "spacers_fasta" in config:
#    mode = "spacer"
#else:
#    raise ValueError("Provide either 'host_table' or 'spacers_fasta' in config.")

workdir:
    output_dir


include:
    "../rules/makeblastdb_host_spacers.smk"

include:
    "../rules/blastn_identity.smk"

rule crispr_links_all:
     input:
        #expand("phage_databases/{phage_db_id}", phage_db_id = phage_dbs.index),
        #expand("spacepharer_dbs/{phage_db_id}", phage_db_id = phage_dbs.index),
        expand(os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}"), phage_db_id = phage_dbs.index),
        expand("host_pilercr/{host_id}.out", host_id = hosts.index),
        expand("host_minced/{host_id}.txt", host_id = hosts.index),
        expand("spacepharer/{host_id}-x-{phage_db_id}/predictions.tsv", phage_db_id = phage_dbs.index, host_id = hosts.index),
        #expand("host_crisprcasfinder/{host_id}/rawCRISPRs.fna", host_id = hosts.index),
        expand("host_crisprcasfinder/{host_id}/result.json", host_id = hosts.index),
        "blast/makeblastdb_spacers.done",
        expand("blast/{phage_db_id}/results/spacers/final_blast.tsv", phage_db_id = phage_dbs.index)
     output: touch("crispr_links.done")

