rule virhostmatcher:
    input:
        virus_dir = "phage_databases/{phage_db_id}",
        host_dir = lambda wildcards: host_dirs.loc[wildcards.host_taxa, "path"],
    output:
        output_dir = "virhostmatcher/{host_taxa}-x-{phage_db_id}" 
    params:
        vhm_script = config["virhostmatcher"]["script"]
    shell:
        """
	python {params.vhm_script} \
        -v {input.virus_dir} \
        -b {input.host_dir} \
        -o {output.output_dir}
        """
