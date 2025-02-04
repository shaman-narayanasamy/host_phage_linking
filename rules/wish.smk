rule genomes_to_one_dir:
    input:
        host_dir = lambda wildcards: host_dirs.loc[wildcards.host_taxa, "path"],
    output: 
        output_dir = directory("{host_taxa}_genomes")
    shell:
        """
        mkdir -p {output.output_dir}

        find {input.host_dir} -type f -name "*.fna" -print0 | \
        xargs -0 -I{{}} sh -c 'ln -s "$1" "{output.output_dir}/$(basename "$1")"' sh {{}}
        """

rule wish_build_model:
    input:
        host_dir = "{host_taxa}_genomes"
    output:
        output_dir = directory("WIsH/{host_taxa}")
    singularity: config["WIsH"]["sif_path"]
    shell:
        """
        mkdir modelDir
        ./WIsH -c build -g prokaryoteGenomesDir -m modelDir        
        """

rule wish_run:
    input:
        host_dir = "{host_taxa}_genomes"
    output:
        output_dir = directory("WIsH/{host_taxa}")
    singularity: config["WIsH"]["sif_path"]
    shell:
        """
        mkdir outputResultDir
        ./WIsH -c predict -g phageContigsDir -m modelDir -r outputResultDir -b 1
        """
