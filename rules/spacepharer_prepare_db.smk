rule spacepharer_prepare_db_phages:
    input:
        multi_fasta = lambda wildcards: phage_dbs.loc[wildcards.phage_db_id, "path"]
    output:
        temp("{phage_db_id}/spacepharer_db.done")
        
    params: 
        output_dir = directory(os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}", "setDbs"))
    conda: "../envs/spacepharer_env.yml"
    resources:
        cpus_per_task = 40,
        mem = "120GB",
        runtime = 7200
    benchmark: "spacepharer_dbs/benchmarks/{phage_db_id}_create_spacepharer_db.txt"
    log: "spacepharer_dbs/logs/{phage_db_id}_create_spacepharer_db.log"
    shell:
         """
         mkdir -p {params.output_dir}
         mkdir -p {tmp_dir}/{wildcards.phage_db_id}/tmpFolder
         mkdir -p {tmp_dir}/{wildcards.phage_db_id}/tmpFolder_rev
         
         spacepharer createsetdb {input.multi_fasta} \
         {params.output_dir}/targetSetDb {tmp_dir}/{wildcards.phage_db_id}/tmpFolder \
         --threads {resources.cpus_per_task} 

	 spacepharer createsetdb {input.multi_fasta} \
         {params.output_dir}/targetSetDb_rev \
         {tmp_dir}/{wildcards.phage_db_id}/tmpFolder_rev --reverse-fragments 1 \
         --threads {resources.cpus_per_task} 

         touch {output}
         """

rule spacepharer_prepare_db_spacers:
    input:
        multi_fasta = config["spacers_fasta"]
    output:
        temp("spacers/spacepharer_db.done")
    params: 
        output_dir = directory(os.path.join(config["outdir"]["spacepharer_db"], "spacers", "setDbs"))
    conda: "../envs/spacepharer_env.yml"
    resources:
        cpus_per_task = 40,
        mem = "120GB",
        runtime = 7200
    benchmark: "spacepharer_dbs/benchmarks/spacers_create_spacepharer_db.txt"
    log: "spacepharer_dbs/logs/spacers_create_spacepharer_db.log"
    shell:
         """
         mkdir -p {params.output_dir}
         mkdir -p {tmp_dir}/spacers/tmpFolder
         mkdir -p {tmp_dir}/spacers/tmpFolder_rev
          
         spacepharer createsetdb {input.multi_fasta} \
         {params.output_dir}/querySetDb {tmp_dir}/spacers/tmpFolder \
         --threads {resources.cpus_per_task} 
         
         touch {output}
         """
