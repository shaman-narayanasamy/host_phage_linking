rule blast_chunks_hosts:
    input:
        donefile = "makeblastdb_hosts.done",
        chunk = "{phage_db_id}/chunks/part_{chunk}.fasta",
    output:
        temp("{phage_db_id}/results/hosts/{chunk}.blast")
    resources:
        cpus_per_task = 24,
        runtime = 7200,
        mem = "100GB"
    conda: "../envs/blast_env.yml"
    shell:
        """
        blastn -query {input.chunk} -db {wildcards.phage_db_id} -task 'blastn' \
            -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' \
            -num_threads {resources.cpus_per_task} > {output}
        """

rule combine_results_hosts:
    input:
        expand("{phage_db_id}/results/hosts/{chunk}.blast", 
               phage_db_id = phage_dbs.index.tolist(), 
               chunk = range(1, config["blastn"]["split"] + 1))  # Removed extra closing parenthesis
    output:
        "{phage_db_id}/results/hosts/final_blast.tsv"
    shell:
        """
        cat {input} > {output}

        sed -i '1i qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tqlen\tqcovs\tsstart\tsend\tslen\tevalue\tbitscore' {output}
        """
