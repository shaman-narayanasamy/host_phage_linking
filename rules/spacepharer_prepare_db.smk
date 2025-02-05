rule create_spacepharer_db:
    input:
        input_dir = os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}")
    output:
        output_dir  = directory(os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}"))
    conda: "../envs/spacepharer_env.yml"
    resources:
         cpus_per_task = 40,
         mem = "120GB",
         runtime = 7200
    benchmark: "spacepharer_dbs/benchmarks/{phage_db_id}_create_spacepharer_db.txt"
    log: "spacepharer_dbs/logs/{phage_db_id}_create_spacepharer_db.log"
    shell:
         """
         mkdir -p {output.output_dir}
         mkdir -p {tmp_dir}/{wildcards.phage_db_id}/tmpFolder
         mkdir -p {tmp_dir}/{wildcards.phage_db_id}/tmpFolder_rev
         
         find {input.input_dir} -name "*.gz" |
         xargs -n 100 -P 10 -I{{}} \
         spacepharer createsetdb --threads 4 {{}} \
         {output.output_dir}/targetSetDb {tmp_dir}/{wildcards.phage_db_id}/tmpFolder

         find {input.input_dir} -name "*.gz" |
         xargs -n 100 -P 10 -I{{}} \
	 spacepharer createsetdb --threads 4 {{}} \
         {output.output_dir}/targetSetDb_rev \
         {tmp_dir}/{wildcards.phage_db_id}/tmpFolder_rev --reverse-fragments 1
         """
