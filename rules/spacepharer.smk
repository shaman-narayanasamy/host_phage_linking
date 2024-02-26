rule spacepharer:
    input:
        host_pilercr_crispr = "host_pilercr/{host_id}.out",
        host_minced_crispr = "host_minced/{host_id}.txt",
        phage_db_dir  = "spacepharer_dbs/{phage_db_id}"
    output:
        predictions = "spacepharer/{host_id}_x_{phage_db_id}/predictions.tsv"
    conda: "../envs/spacepharer_env.yml"
    benchmark: "spacepharer/{host_id}_x_{phage_db_id}/benchmarks/spacepharer.txt"
    log: "spacepharer/{host_id}_x_{phage_db_id}/logs/spacepharer.txt"
    shell:
        """ 
        mkdir -p spacepharer/{wildcards.host_id}_x_{wildcards.phage_db_id}

        # Need an if statement to ensure that the CRISPR files are not empty
        if [ $(wc -l < {input.host_pilercr_crispr}) -gt 5 ] && [ -s {input.host_minced_crispr} ]; then

            mkdir -p {tmp_dir}/tmpFolder/{wildcards.host_id}_x_{wildcards.phage_db_id}
    
    	    spacepharer easy-predict {input.host_pilercr_crispr} \
            {input.host_minced_crispr} \
            {input.phage_db_dir}/targetSetDb {output} \
            {tmp_dir}/tmpFolder/{wildcards.host_id}_x_{wildcards.phage_db_id}
        else
            touch {output}
        fi
        """ 
