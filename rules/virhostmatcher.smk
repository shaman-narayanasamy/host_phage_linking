rule virhostmatcher:
    input:
        virus_dir = "phage_databases/{phage_db_id}",
        host_dir = config["host_dir"]
    output:
        output_dir = "virhostmatcher/{phage_db_id}" 
    params:
        vhm_script = config["virhostmatcher"]["script"]
    shell:
        """
	python {params.vhm_script} \
        -v {input.virus_dir} \
        -b {input.host_dir} \
        -o {output.output_dir}
        """
