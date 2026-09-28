rule make_blast_db_phages:
    input:
        phage_fasta = lambda wildcards: phage_dbs.loc[wildcards.phage_db_id, "path"],
    output:
        donefile = touch("blast/{phage_db_id}/makeblastdb.done")
    resources: 
        runtime = 7200,
        mem = "120GB"
    conda: "../envs/blast_env.yml"
    params:
        db_prefix = "{phage_db_id}_seqs_db",
    benchmark: "benchmarks/blast/{phage_db_id}/make_blast_db.txt"
    #group: "make_blast_db"
    shell:
        """
        makeblastdb -in {input.phage_fasta} -dbtype nucl -out blast/{params.db_prefix}

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
