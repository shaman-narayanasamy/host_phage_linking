rule split_fasta:
    input:
        fasta = lambda wildcards: phage_dbs.loc[wildcards.phage_db_id, "path"],
    output:
        temp("blast/{phage_db_id}/chunks/split.done")
    params:
        splits = config["blastn"]["split"],
    resources: 
        cpus_per_task = 24,
        runtime = 7200,
        mem = "100GB"
    conda: "../envs/seqkit_env.yml"
    shell:
        """
        seqkit split {input.fasta} --by-part {params.splits} --by-part-prefix split_part_ \
        --out-dir blast/{wildcards.phage_db_id}/chunks --force -j {resources.cpus_per_task}

        # Ensure all chunk files use .fasta extension
        for file in blast/{wildcards.phage_db_id}/chunks/*; do
            mv "$file" "${{file%.*}}.fasta"
        done
       
        for file in blast/{wildcards.phage_db_id}/chunks/split_part_*.fasta; do

            # Extract the numeric part, removing leading zeros
            num=$(basename "$file" | sed -E 's/split_part_0*([0-9]+)\.fasta/\\1/')
        
            # Construct the new filename
            new_file="blast/{wildcards.phage_db_id}/chunks/split_part_${{num}}.fasta"
        
            # Only rename if the filenames are different
            if [[ "$file" != "$new_file" ]]; then
                echo "Renaming: $file -> $new_file"
                mv "$file" "$new_file"
            else
                echo "Skip renaming: $file"
            fi
        done
        
        touch {output}
        """

rule check_chunk:
    input:
        "blast/{phage_db_id}/chunks/split.done"
    output:
        temp("blast/{phage_db_id}/chunks/split_part_{chunk}.fasta")
