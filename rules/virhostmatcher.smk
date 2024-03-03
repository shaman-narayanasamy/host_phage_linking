rule genomes_to_one_dir:
    input:
        host_dir = lambda wildcards: host_dirs.loc[wildcards.host_taxa, "path"],
    output: 
        output_dir = directory("{host_taxa}_genomes")
    shell:
        """
        mkdir -p {output.output_dir}

        find {input.host_dir} -type f -name "*.fna" -print0 | \
        xargs -0 -I{{}} sh -c 'ln -s "$1" "test_host_dir/$(basename "$1")"' sh {{}}
        """

rule virhostmatcher:
    input:
        virus_dir = "phage_databases/{phage_db_id}",
        host_dir = "{host_taxa}_genomes"
    output:
        output_dir = directory("virhostmatcher/{host_taxa}-x-{phage_db_id}")
    params:
        vhm_script = config["virhostmatcher"]["script"]
    shell:
        """
	python {params.vhm_script} \
        -v {input.virus_dir} \
        -b {input.host_dir} \
        -o {output.output_dir}
        """

        #host_dir = lambda wildcards: host_dirs.loc[wildcards.host_taxa, "path"],
