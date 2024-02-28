rule create_spacepharer_db:
    input:
        input_dir = "phage_databases/{phage_db_id}"
    output:
        output_dir  = directory("spacepharer_dbs/{phage_db_id}")
    conda: "../envs/spacepharer_env.yml"
    benchmark: "spacepharer_dbs/benchmarks/{phage_db_id}_create_spacepharer_db.txt"
    log: "spacepharer_dbs/logs/{phage_db_id}_create_spacepharer_db.log"
    shell:
         """
         mkdir -p {output.output_dir}
         mkdir -p {tmp_dir}/{wildcards.phage_db_id}/tmpFolder
         mkdir -p {tmp_dir}/{wildcards.phage_db_id}/tmpFolder_rev

	 spacepharer createsetdb phage_databases/{wildcards.phage_db_id}/*.{{fna,fa}}.gz \
         {output.output_dir}/targetSetDb {tmp_dir}/{wildcards.phage_db_id}/tmpFolder

	 spacepharer createsetdb phage_databases/{wildcards.phage_db_id}/*.{{fna,fa}}.gz \
         {output.output_dir}/targetSetDb_rev {tmp_dir}/{wildcards.phage_db_id}/tmpFolder_rev --reverse-fragments 1
         """
