#        input_dir = lambda wildcards: os.path.join(config["outdir"]["spacepharer_db"], wildcards.phage_db_id)
#        input_dir = os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}")

rule spacepharer_prepare_db:
    input:
        input_dir = os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}"),
        donefile = "{phage_db_id}/fasta_split.done"
    output:
        temp("{phage_db_id}/spacepharer_db.done")
    params: 
        output_dir = directory(os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}"))
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
         
         spacepharer createsetdb --threads 4 {input.input_dir} \
         {params.output_dir}/targetSetDb {tmp_dir}/{wildcards.phage_db_id}/tmpFolder

	 spacepharer createsetdb --threads 4 {input.input_dir} \
         {params.output_dir}/targetSetDb_rev \
         {tmp_dir}/{wildcards.phage_db_id}/tmpFolder_rev --reverse-fragments 1

         touch {output}
         """
         #find {input.input_dir} -name "*.fasta" |
         #xargs -n 100 -P 10 -I{{}} \
#         find {input.input_dir} -name "*.fasta" |
#         xargs -n 100 -P 10 -I{{}} \

