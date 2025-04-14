rule split_fasta_repeats:
    input:
        concatenated_fasta = config["repeats_fasta"]
    output:
        temp(expand("blast/chunks/repeats.part_{i}.fasta", i = range(1, config["blastn"]["split"] + 1)))
    params:
        splits = config["blastn"]["split"]
    resources: 
        cpus_per_task = 24,
        runtime = 7200,
        mem = "100GB"
    conda: "../envs/seqkit_env.yml"
    benchmark: "benchmarks/blast/split_fasta.txt"
    group: "split_fasta"
    shell:
        """
        ln -s {input.concatenated_fasta} repeats.fasta

        seqkit split repeats.fasta --by-part {params.splits} \
        --out-dir blast/chunks --force -j {resources.cpus_per_task}
         
        for file in blast/chunks/repeats.part_*.fasta; do
            # Extract the numeric part, removing leading zeros
            num=$(basename "$file" | sed -E 's/.*part_0*([0-9]+)\.fasta/\\1/')
        
            # Construct the new filename
            new_file="blast/chunks/repeats.part_${{num}}.fasta"
        
            # Only rename if the filenames are different
            if [[ "$file" != "$new_file" ]]; then
                echo "Renaming: $file -> $new_file"
                mv "$file" "$new_file"
            else
                echo "Skip renaming: $file"
            fi
        done
        """
 
rule blast_chunks_repeats:
    input:
        donefile = "blast/hosts/makeblastdb.done",
        chunk = "blast/chunks/repeats.part_{chunk}.fasta"
    output:
        temp("blast/results/repeats/{chunk}.blast")
    resources:
        cpus_per_task = 48,
        runtime = 7200,
        mem = "120GB"
    params:
        db_prefix = "concatenated_host_seqs_db",
    conda: "../envs/blast_env.yml"
    benchmark: "benchmarks/blast/repeats/{chunk}.txt"
    group: "blast_chunks"
    shell:
        """
        blastn -query {input.chunk} -db blast/hosts/{params.db_prefix} -task 'blastn-short' \
            -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' \
            -num_threads {resources.cpus_per_task} > {output}
        """
        #blastn -task blastn-short -query repeats.fasta -db query_database -outfmt 6
        #-outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend qlen qcovs sstart send slen evalue bitscore" \

rule combine_results_repeats:
    input:
        expand("blast/results/repeats/{chunk}.blast", chunk=range(1, config["blastn"]["split"] + 1))  # Adjust for the number of splits
    output:
        "blast/results/repeats/final_blast.tsv"
    benchmark: "benchmarks/blast/repeats_combine_results.txt"
    shell:
        """
        cat {input} > {output}

        sed -i '1i qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tqlen\tqcovs\tsstart\tsend\tslen\tevalue\tbitscore' {output}
        """
