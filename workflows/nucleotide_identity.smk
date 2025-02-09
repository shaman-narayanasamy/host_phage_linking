import subprocess
import pandas as pd

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define output directory
#output_dir = config["output_dir"]

## Define input files

# Read the host genome table (individually listed)
hosts = pd.read_table(config["host_table"], sep="\t", comment = "#").set_index("ID", drop=False)

# Read the phage table
phage_dbs = pd.read_table(config["phage_db_table"], sep="\t", comment = "#").set_index("ID", drop=False)

print("Available phage_db_ids:", list(phage_dbs.index))

workdir:
    output_dir

include:
    "../rules/genomad.smk"

include:
    "../rules/makeblastdb_host_genomes.smk"

include:
    "../rules/blastn_nucleotide_identity.smk"

rule nucleotide_identity_all:
     input:
        "concatenated_hosts.fasta",
        "blast/makeblastdb_hosts.done",
        expand("blast/{phage_db_id}/results/hosts/final_blast.tsv", phage_db_id = phage_dbs.index),
        expand("host_genomad/{host_id}/genomic_find_proviruses/genomic_find_proviruses.json", host_id = hosts.index)
     output: touch("nucleotide_identity.done")
