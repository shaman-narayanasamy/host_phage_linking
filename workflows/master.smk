import subprocess
import pandas as pd

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define output directory
output_dir = config["output_dir"]

## Define input files

# Read the host taxa directories
host_dirs = pd.read_table(config["host_taxa_table"], sep="\t", comment = "#").set_index("ID", drop=False)

# Read the host genome table (individually listed)
hosts = pd.read_table(config["host_table"], sep="\t", comment = "#").set_index("ID", drop=False)

# Read the phage table
phage_dbs = pd.read_table(config["phage_db_table"], sep="\t", comment = "#").set_index("ID", drop=False)

workdir:
    output_dir

print(phage_dbs)

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
    "../rules/genomad.smk"

include:
    "../rules/virhostmatcher.smk"

rule all:
     input:
        expand("phage_databases/{phage_db_id}", phage_db_id = phage_dbs.index),
        expand("spacepharer_dbs/{phage_db_id}", phage_db_id = phage_dbs.index),
        expand("host_pilercr/{host_id}.out", host_id = hosts.index),
        expand("host_minced/{host_id}.txt", host_id = hosts.index),
        expand("spacepharer/{host_id}-x-{phage_db_id}/predictions.tsv", phage_db_id = phage_dbs.index, host_id = hosts.index),
        expand("host_genomad/{host_id}", host_id = hosts.index),
        expand("virhostmatcher/{host_taxa}-x-{phage_db_id}", host_taxa = host_dirs.index, phage_db_id = phage_dbs.index)
