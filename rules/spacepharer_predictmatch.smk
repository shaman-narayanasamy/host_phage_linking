rule spacepharer_predictmatch:
    input:
        phage_db_done = "spacepharer/dbs/{phage_db_id}/spacepharer_db.done",
        spacers_db_done = "spacepharer/dbs/spacers/spacepharer_db.done"
    output:
        predictions = "spacepharer/{phage_db_id}/predictions.tsv"
    resources: 
        cpus_per_task = 40,
        runtime = 7200,
        mem = "250GB"
    params: 
        query_set_db = directory(os.path.join("spacepharer", "dbs", "spacers", "setDbs/querySetDb")),
        target_set_db = directory(os.path.join("spacepharer", "dbs", "{phage_db_id}", "setDbs/targetSetDb")),
        target_set_db_rev = directory(os.path.join("spacepharer", "dbs", "{phage_db_id}", "setDbs/targetSetDb_rev"))
    conda: "../envs/spacepharer_env.yml"
    benchmark: "spacepharer/spacers-x-{phage_db_id}/benchmarks/spacepharer.txt"
    log: "spacepharer/spacers-x-{phage_db_id}/logs/spacepharer.txt"
    shell:
        """ 
        rm -rf spacepharer/{wildcards.phage_db_id}
        rm -rf {tmp_dir}/spacepharer/tmpFolder_predictions

        mkdir -p spacepharer/{wildcards.phage_db_id}

        mkdir -p {tmp_dir}/spacepharer/tmpFolder_predictions

	spacepharer predictmatch {params.query_set_db} \
        {params.target_set_db} \
        {params.target_set_db_rev} \
        spacepharer/predictions.tsv \
        --threads {resources.cpus_per_task} \
        {tmp_dir}/spacepharer/tmpFolder_predictions
        """

