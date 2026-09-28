rule split_fasta_spacers:
    input:
        concatenated_fasta = config["spacers_fasta"]
    output:
        temp(expand("blast/chunks/spacers/spacers.part_{i}.fasta", i = range(1, config["blastn"]["split"] + 1)))
    params:
        splits = config["blastn"]["split"]
    resources: 
        cpus_per_task = 24,
        runtime = 7200,
        mem = "100GB"
    conda: "../envs/seqkit_env.yml"
    benchmark: "benchmarks/blast/split_fasta.txt"
    #group: "blast_chunks"
    shell:
        """
        ln -fs {input.concatenated_fasta} spacers.fasta
         
        seqkit split spacers.fasta --by-part {params.splits} \
        --out-dir blast/chunks/spacers --force -j {resources.cpus_per_task}
         
        for file in blast/chunks/spacers/spacers.part_*.fasta; do
            # Extract the numeric part, removing leading zeros
            num=$(basename "$file" | sed -E 's/.*part_0*([0-9]+)\\.fasta/\\1/')
         
            # Construct the new filename
            new_file="blast/chunks/spacers/spacers.part_${{num}}.fasta"
         
            # Only rename if the filenames are different
            if [[ "$file" != "$new_file" ]]; then
                echo "Renaming: $file -> $new_file"
                mv "$file" "$new_file"
            else
                echo "Skip renaming: $file"
            fi
        done
        """
 
rule blast_chunks_spacers:
    input:
        donefile = "blast/{phage_db_id}/makeblastdb.done",
        chunk = "blast/chunks/spacers/spacers.part_{chunk}.fasta"
    output:
        temp("blast/results/spacers/{phage_db_id}_{chunk}.blast")
    resources:
        cpus_per_task = 48,
        runtime = 7200,
        mem = "120GB"
    params:
        db_prefix = "{phage_db_id}_seqs_db",
    conda: "../envs/blast_env.yml"
    benchmark: "benchmarks/blast/spacers/{phage_db_id}/{chunk}.txt"
    #group: "blast_chunks"
    shell:
        """
        blastn -query {input.chunk} -db blast/{params.db_prefix} -task 'blastn-short' \
            -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend qlen qcovs sstart send evalue bitscore slen' \
            -num_threads {resources.cpus_per_task} > {output}
        """

        #blastn -task blastn-short -query spacers.fasta -db query_database -outfmt 6
        #-outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend qlen qcovs sstart send slen evalue bitscore" 

rule combine_results_spacers:
    input:
        expand("blast/results/spacers/{phage_db_id}_{chunk}.blast", phage_db_id = phage_dbs.index, 
                chunk=range(1, config["blastn"]["split"] + 1))  # Adjust for the number of splits
    output:
        "blast/results/spacers/{phage_db_id}_final_blast.tsv"
    benchmark: "benchmarks/{phage_db_id}_combine_results.txt"
    shell:
        """
        cat {input} > {output}

         sed -i \
        '1i qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tqlen\tqcovs\tsstart\tsend\tevalue\tbitscore\tslen' \
        {output}
        """
