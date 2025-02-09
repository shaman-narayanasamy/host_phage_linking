rule concatenate_host_genomes:
    input:
        fasta=lambda wildcards: hosts["path"].tolist()
    output:
        concatenated_fasta = "concatenated_hosts.fasta"
    shell:
        """
        cat {input} > {output}
        """

rule make_blast_db_host_genomes:
    input:
        concatenated_fasta = "concatenated_hosts.fasta"
    output:
        donefile = touch("blast/makeblastdb_hosts.done")
    resources: 
        runtime = 7200,
        mem = "120GB"
    conda: "../envs/blast_env.yml"
    params:
        db_prefix = "concatenated_hosts",
    benchmark: "benchmarks/make_blast_db.txt"
    shell:
        """
        makeblastdb -in {input.concatenated_fasta} -dbtype nucl -out {params.db_prefix}

        # Define a function to check for the existence of all expected output files
        check_outputs() {{
            for ext in nhr nin nsq ndb njs not ntf nto; do
                if [ ! -f {params.db_prefix}.$ext ]; then
                    return 1
                fi
            done
            return 0
        }}
        """

