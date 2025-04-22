import subprocess
import pandas as pd

## Define output directory
output_dir = os.path.join(config["outdir"]["root"], config["outdir"]["subdir"], "identity_links")
tmp_dir = config["tmp_dir"]

## Define input files
hosts = None

# Read the phage table
phage_dbs = pd.read_table(config["phage_db_table"], sep="\t", comment = "#").set_index("ID", drop=False)

# Read the host table
hosts = pd.read_table(config["host_table"], sep="\t", comment = "#").set_index("ID", drop=False)

workdir:
    output_dir

include:
    "../rules/makeblastdb_host_genomes.smk"

include:
    "../rules/blastn_identity.smk"


chunk_outputs = expand(
    "blast/chunks/{phage_db_id}.part_{i}.fasta",
    phage_db_id=phage_dbs.index,
    i=range(1, config["blastn"]["split"] + 1)
)

rule identity_links_all:
     input:
        expand("blast/chunks/{phage_db_id}.part_{i}.fasta", phage_db_id=phage_dbs.index, i=range(1, config["blastn"]["split"] + 1)),

        expand("blast/results/{phage_db_id}/final_blast.tsv", phage_db_id = phage_dbs.index),
     output: touch("crispr_links.done")
