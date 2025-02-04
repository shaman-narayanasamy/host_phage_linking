import subprocess
import pandas as pd

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define output directory
output_dir = config["output_dir"]

## Define input files

# Read the host taxa directories
#host_dirs = pd.read_table(config["host_taxa_table"], sep="\t", comment = "#").set_index("ID", drop=False)

# Read the host genome table (individually listed)
hosts = pd.read_table(config["host_table"], sep="\t", comment = "#").set_index("ID", drop=False)

# Read the phage table
phage_dbs = pd.read_table(config["phage_db_table"], sep="\t", comment = "#").set_index("ID", drop=False)

workdir:
    output_dir

include:
    "../rules/prepare_data.smk"

include:
    "../rules/spacepharer_prepare_db.smk"

include:
    "../rules/pilercr.smk"

include:
    "../rules/minced.smk"

include:
    "../rules/spacepharer.smk"

include:
    "../rules/crisprcasfinder.smk"

include:
    "../rules/makeblastdb_host_spacers.smk"

include:
    "../rules/blastn_crispr.smk"

rule crispr_links_all:
     input:
        expand("phage_databases/{phage_db_id}", phage_db_id = phage_dbs.index),
        expand("spacepharer_dbs/{phage_db_id}", phage_db_id = phage_dbs.index),
        expand("host_pilercr/{host_id}.out", host_id = hosts.index),
        expand("host_minced/{host_id}.txt", host_id = hosts.index),
        expand("spacepharer/{host_id}-x-{phage_db_id}/predictions.tsv", phage_db_id = phage_dbs.index, host_id = hosts.index),
        expand("host_crisprcasfinder/{host_id}/{host_id}/rawCRISPRs.fna", host_id = hosts.index),
        "makeblastdb_spacers.done",
        expand("{phage_db_id}/results/spacers/final_blast.tsv", phage_db_id = phage_dbs.index)
     output: touch("crispr_links.done")

