rule spacepharer_spacers:
    input:
        spacers = config["spacers_fasta"],
        donefile = "spacepharer/dbs/{phage_db_id}/spacepharer_db.done"
    output:
        predictions = "spacepharer/spacers-x-{phage_db_id}/predictions.tsv"
    params:
        target_set_db = os.path.join("spacepharer", "dbs", "{phage_db_id}", "setDbs/targetSetDb"),
        target_set_db_rev = os.path.join("spacepharer", "dbs", "{phage_db_id}", "setDbs/targetSetDb_rev")
    resources: 
        cpus_per_task = 48,
        runtime = 7200,
        mem = "250GB"
    conda: "../envs/spacepharer_env.yml"
    benchmark: "spacepharer/spacers-x-{phage_db_id}/benchmarks/spacepharer.txt"
    log: "spacepharer/spacers-x-{phage_db_id}/logs/spacepharer.txt"
    shell:
        """ 
        mkdir -p spacepharer/spacers-x-{wildcards.phage_db_id}
        mkdir -p {tmp_dir}/tmpFolder/spacers-x-{wildcards.phage_db_id}
            
    	spacepharer easy-predict {input.spacers} \
        {params.target_set_db} {output.predictions} \
        {tmp_dir}/spacepharer/tmpFolder/spacers-x-{wildcards.phage_db_id} \
        --threads {resources.cpus_per_task}
        """ 

        #set +e
        #rm -rf spacepharer/spacers-x-{wildcards.phage_db_id} || true
        #rm -rf {tmp_dir}/tmpFolder/spacers-x-{wildcards.phage_db_id} || true
        #set -e

#spacepharer easy-predict host_pilercr/93_MAGScoT_cleanbin_000045.out     host_minced/93_MAGScoT_cleanbin_000045.txt         spacepharer/dbs/test_virome/setDbs/targetSetDb spacepharer/93_MAGScoT_cleanbin_000045-x-test_virome/predictions.tsv             /tmp/chekc             --threads 4
