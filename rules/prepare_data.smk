# The software requires the phages and hosts to be in individual fasta files.
# Typically, bacterial genomes already exist as individual fasta files, but
# phage genomes, especially from newer databases, are grouped into a
# multi-fasta file, which needs to be split.

rule split_phage_fasta:
    """ 
    The software requires the phages and hosts to be in individual fasta files.
    Typically, bacterial genomes already exist as individual fasta files, but
    phage genomes, especially from newer databases, are grouped into a
    multi-fasta file, which needs to be split.
    """
    input:
        multi_fasta = lambda wildcards: phage_dbs.loc[wildcards.phage_db_id, "path"]
    output:
        temp("{phage_db_id}/fasta_split.done")
    params:
        output_dir = directory(os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}", "split_fasta_files"))
    conda: "../envs/seqkit_env.yml"
    resources: 
        cpus_per_task = 12,
        runtime = 7200,
        mem = "200GB"
    shell:
         """
         mkdir -p {params.output_dir}

         if [ -d {input.multi_fasta} ]; then
             echo "{input.multi_fasta} is already a folder likely with multiple fasta files."
             echo "Creating soft link for {params.output_dir}"
             ln -s $(realpath {input.multi_fasta}) $(realpath {params.output_dir})
             touch {params.output_dir}
         else
             seqkit -j {resources.cpus_per_task} split --by-id {input.multi_fasta} \
             --extension .fasta \
             -O {params.output_dir}
         fi
         
         touch {output}
         """
