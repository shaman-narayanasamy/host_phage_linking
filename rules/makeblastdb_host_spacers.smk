rule concatenate_spacers:
    input:
        expand("host_crisprcasfinder/{host_id}/rawCRISPRs.fna", 
        host_id = hosts.index)
    output:
        concatenated_fasta = "concatenated_spacers.fasta"
    shell:
        """
        cat $(find host_crisprcasfinder -name "rawCRISPRs.fna" -size +0) > {output}
        """

rule make_blast_db_spacers:
    input:
        concatenated_fasta = "concatenated_spacers.fasta"
    output:
        donefile = touch("blast/makeblastdb_spacers.done")
    resources: 
        runtime = 7200,
        mem = "120GB"
    conda: "../envs/blast_env.yml"
    params:
        db_prefix = "concatenated_spacers",
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
