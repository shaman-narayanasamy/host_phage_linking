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

include:
    "../rules/crisprcasfinder.smk"

rule all:
     input:
        expand("host_crisprcasfinder/{host_id}", host_id = hosts.index)
