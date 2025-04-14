rule concatenate_host_genomes:
    input:
        fasta=lambda wildcards: hosts["path"].tolist()
    output:
        concatenated_fasta = "concatenated_hosts.fasta"
    shell:
        """
        cat {input} > {output}
        """

#rule concatenate_phage_genomes:
#   input:
#       fasta=lambda wildcards: hosts["path"].tolist()
#   output:
#       concatenated_fasta = "concatenated_hosts.fasta"
#   shell:
#       """
#       cat {input} > {output}
#       """

rule make_blast_db_hosts:
    input:
        host_concatenated_fasta = "concatenated_hosts.fasta"
    output:
        donefile = touch("blast/hosts/makeblastdb.done")
    resources: 
        runtime = 7200,
        mem = "120GB"
    conda: "../envs/blast_env.yml"
    params:
        db_prefix = "concatenated_host_seqs_db",
    benchmark: "benchmarks/blast/hosts/make_blast_db.txt"
    group: "make_blast_db"
    shell:
        """
        makeblastdb -in {input.host_concatenated_fasta} -dbtype nucl -out blast/hosts/{params.db_prefix}

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
