rule spacepharer_predictmatch:
    input:
        phage_db_done = "{phage_db_id}/spacepharer_db.done",
        spacers_db_done = "spacers/spacepharer_db.done"
    output:
        predictions = "spacepharer/{phage_db_id}/predictions.tsv"
    resources: 
        cpus_per_task = 40,
        runtime = 7200,
        mem = "200GB"
    params: 
        output_dir = directory(os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}", "setDbs"))
    conda: "../envs/spacepharer_env.yml"
    benchmark: "spacepharer/spacers-x-{phage_db_id}/benchmarks/spacepharer.txt"
    log: "spacepharer/spacers-x-{phage_db_id}/logs/spacepharer.txt"
    shell:
        """ 
        mkdir -p spacepharer

	spacepharer predictmatch {params.output_dir}/querySetDb \
        {params.output_dir}/targetSetDb \
        {params.output_dir}/targetSetDb_rev \
        spacepharer/predictions.tsv \
        {tmp_dir}/spacepharer/tmpFolder_predictions
        """

