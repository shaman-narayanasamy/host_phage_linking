rule split_fasta:
    input:
        concatenated_fasta = lambda wildcards: phage_dbs.loc[wildcards.phage_db_id, "path"],
    output:
        temp(expand("blast/chunks/{phage_db_id}.part_{i}.fasta", i = range(1, config["blastn"]["split"] + 1)))
    params:
        splits = config["blastn"]["split"]
    resources: 
        cpus_per_task = 24,
        runtime = 7200,
        mem = "100GB"
    conda: "../envs/seqkit_env.yml"
    benchmark: "benchmarks/split_fasta.txt"
    shell:
        """
        ln -s {input.concatenated_fasta} {wildcards.phage_db_id}.fasta

        seqkit split {wildcards.phage_db_id}.fasta --by-part {params.splits} \
        --out-dir blast/chunks --force -j {resources.cpus_per_task}
         
        for file in blast/chunks/{wildcards.phage_db_id}.part_*.fasta; do
            # Extract the numeric part, removing leading zeros
            num=$(basename "$file" | sed -E 's/.*part_0*([0-9]+)\.fasta/\\1/')
        
            # Construct the new filename
            new_file="blast/chunks/{wildcards.phage_db_id}.part_${{num}}.fasta"
        
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
        chunk = "chunks/{phage_db_id}/{phage_db_id}.part_{chunk}.fasta"
    output:
        temp("results/{phage_db_id}/{chunk}.blast")
    resources:
        cpus_per_task = 48,
        runtime = 7200,
        mem = "120GB"
    params:
        db_prefix = "concatenated_seqs_db"
    conda: "../envs/blast_env.yml"
    benchmark: "benchmarks/blast_chunks/{chunk}.txt"
    shell:
        """
        blastn -query {input.chunk} -db {params.db_prefix} -task 'blastn' \
            -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' \
            -num_threads {resources.cpus_per_task} > {output}
        """

rule combine_results:
    input:
        expand("results/{phage_db_id}/{chunk}.blast", chunk=range(1, config["blastn"]["split"] + 1))  # Adjust for the number of splits
    output:
        "results/final_blast.tsv"
    benchmark: "benchmarks/combine_results.txt"
    shell:
        """
        cat {input} > {output}

        sed -i '1i qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tqlen\tqcovs\tsstart\tsend\tslen\tevalue\tbitscore' {output}
        """
