rule spacepharer_genomes:
    input:
        host_pilercr_crispr = "host_pilercr/{host_id}.out",
        host_minced_crispr = "host_minced/{host_id}.txt",
        #phage_db_dir  = "spacepharer/dbs/{phage_db_id}"
        #phage_db_dir  = os.path.join(config["outdir"]["spacepharer_dbs"]/{phage_db_id}")
        #donefile = "spacepharer/dbs/{phage_db_id}/spacepharer_db.done"
        donefile = "spacepharer/dbs/{phage_db_id}/spacepharer_db.done"
    output:
        predictions = "spacepharer/{host_id}-x-{phage_db_id}/predictions.tsv"
    params:
        #target_set_db = os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}", "setDbs/targetSetDb"),
        #target_set_db_ref = os.path.join(config["outdir"]["spacepharer_db"], "{phage_db_id}", "setDbs/targetSetDb_rev")
        target_set_db = os.path.join("spacepharer", "dbs", "{phage_db_id}", "setDbs/targetSetDb"),
        target_set_db_rev = os.path.join("spacepharer", "dbs", "{phage_db_id}", "setDbs/targetSetDb_rev"),
        tmp_workdir = os.path.join(tmp_dir, "spacepharer", "tmpFolder", "{host_id}-x-{phage_db_id}")
    resources: 
        cpus_per_task = 12,
        runtime = 7200,
        mem = "200GB"
    conda: "../envs/spacepharer_env.yml"
    benchmark: "spacepharer/{host_id}-x-{phage_db_id}/benchmarks/spacepharer.txt"
    log: "spacepharer/{host_id}-x-{phage_db_id}/logs/spacepharer.txt"
    shell:
        """ 
        #rm -rf spacepharer/{wildcards.host_id}-x-{wildcards.phage_db_id}
        #rm -rf {params.tmp_workdir}

        mkdir -p spacepharer/{wildcards.host_id}-x-{wildcards.phage_db_id}
         
        # Need an if statement to ensure that the CRISPR files are not empty
        if [ $(wc -l < {input.host_pilercr_crispr}) -gt 5 ] && [ -s {input.host_minced_crispr} ]; then
        
            mkdir -p {params.tmp_workdir}
            
    	    spacepharer easy-predict {input.host_pilercr_crispr} \
            {input.host_minced_crispr} \
            {params.target_set_db} {output.predictions} \
            {params.tmp_workdir} \
            --threads {resources.cpus_per_task}
        else
            touch {output.predictions}
        fi
        """ 
