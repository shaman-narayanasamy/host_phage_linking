rule split_fasta:
    input:
        concatenated_fasta = phage_seqs,
    output:
        temp(expand("blast/chunks/phages.part_{i}.fasta", i = range(1, config["blastn"]["split"] + 1)))

    params:
        splits = config["blastn"]["split"]
    resources: 
        cpus_per_task = 24,
        runtime = 7200,
        mem = "100GB"
    conda: "../envs/seqkit_env.yml"
    benchmark: "benchmarks/phages/split_fasta.txt"
    shell:
        """
        ln -fs {input.concatenated_fasta} phages.fasta

        seqkit split phages.fasta --by-part {params.splits} \
        --out-dir blast/chunks --force -j {resources.cpus_per_task}
         
        for file in blast/chunks/phages.part_*.fasta; do
            # Extract the numeric part, removing leading zeros
            num=$(basename "$file" | sed -E 's/.*part_0*([0-9]+)\\.fasta/\\1/')
        
            # Construct the new filename
            new_file="blast/chunks/phages.part_${{num}}.fasta"
        
            # Only rename if the filenames are different
            if [[ "$file" != "$new_file" ]]; then
                echo "Renaming: $file -> $new_file"
                mv "$file" "$new_file"
            else
                echo "Skip renaming: $file"
            fi
        done
        """
 
rule blast_chunks:
    input:
        donefile = "blast/hosts/makeblastdb.done",
        chunk = "blast/chunks/phages.part_{chunk}.fasta"
    output:
        temp("blast/results/phages/{chunk}.blast")
    resources:
        cpus_per_task = 48,
        runtime = 7200,
        mem = "120GB"
    params:
        db_prefix = "concatenated_host_seqs_db"
    conda: "../envs/blast_env.yml"
    benchmark: "benchmarks/blast_chunks/phages/{chunk}.txt"
    shell:
        """
        blastn -query {input.chunk} -db blast/hosts/{params.db_prefix} -task 'blastn' \
            -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend qlen qcovs sstart send evalue bitscore slen' \
            -num_threads {resources.cpus_per_task} > {output}
        """

rule combine_results:
    input:
        expand("blast/results/phages/{chunk}.blast", chunk=range(1, config["blastn"]["split"] + 1))  # Adjust for the number of splits
    output:
        "blast/results/phages/final_blast.tsv"
    benchmark: "benchmarks/phages/combine_results.txt"
    shell:
        """
        cat {input} > {output}

        sed -i \
        '1i qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tqlen\tqcovs\tsstart\tsend\tevalue\tbitscore\tslen' \
        {output}
        """

