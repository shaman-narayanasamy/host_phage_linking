import subprocess
import pandas as pd

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define output directory
output_dir = os.path.join(config["outdir"]["root"], config["outdir"]["subdir"])

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
    "../rules/split_phage_sequences.smk"

include:
    "crispr_links.smk"

include:
    "nucleotide_identity.smk"

rule all:
    input: 
        "crispr_links.done",
        "nucleotide_identity.done",
