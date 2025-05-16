import subprocess
import pandas as pd

## Define output directory
output_dir = os.path.join(config["outdir"]["root"], config["outdir"]["subdir"], "identity_links")
tmp_dir = config["tmp_dir"]

## Define input files
hosts = None

# Read the phage table
#phage_dbs = pd.read_table(config["phage_db_table"], sep="\t", comment = "#").set_index("ID", drop=False)
phage_seqs = config["phage_seqs"]

# Read the host table
hosts = pd.read_table(config["host_table"], sep="\t", comment = "#").set_index("ID", drop=False)

workdir:
    output_dir

include:
    "../rules/makeblastdb_host_genomes.smk"

include:
    "../rules/blastn_identity.smk"


rule identity_links_all:
     input:
        "blast/results/phages/final_blast.tsv"
     output: touch("crispr_links.done")
