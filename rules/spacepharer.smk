rule spacepharer:
    input:
        host_pilercr_crispr = "host_pilercr/{host_id}.out",
        host_minced_crispr = "host_minced/{host_id}.txt",
        #phage_db_dir  = "spacepharer_dbs/{phage_db_id}"
        #phage_db_dir  = os.path.join(config["outdir"]["spacepharer_dbs"]/{phage_db_id}")
        donefile = "spacepharer/dbs/{phage_db_id}/spacepharer_db.done"
    output:
        predictions = "spacepharer/{host_id}-x-{phage_db_id}/predictions.tsv"
    params:
        target_set_db = os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}", "setDbs/targetSetDb"),
        target_set_db_ref = os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}", "setDbs/targetSetDb_rev")
    resources: 
        cpus_per_task = 12,
        runtime = 7200,
        mem = "200GB"
    conda: "../envs/spacepharer_env.yml"
    benchmark: "spacepharer/{host_id}-x-{phage_db_id}/benchmarks/spacepharer.txt"
    log: "spacepharer/{host_id}-x-{phage_db_id}/logs/spacepharer.txt"
    shell:
        """ 
        mkdir -p spacepharer/{wildcards.host_id}-x-{wildcards.phage_db_id}
         
        # Need an if statement to ensure that the CRISPR files are not empty
        if [ $(wc -l < {input.host_pilercr_crispr}) -gt 5 ] && [ -s {input.host_minced_crispr} ]; then
        
            mkdir -p {tmp_dir}/tmpFolder/{wildcards.host_id}-x-{wildcards.phage_db_id}
            
    	    spacepharer easy-predict {input.host_pilercr_crispr} \
            {input.host_minced_crispr} \
            {input.phage_db_dir}/targetSetDb {output} \
            {tmp_dir}/tmpFolder/{wildcards.host_id}-x-{wildcards.phage_db_id} \
            --threads {resources.cpus_per_task}

        else
            touch {output}
        fi
        """ 
