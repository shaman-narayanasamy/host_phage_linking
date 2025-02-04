rule split_fasta:
    input:
        fasta = lambda wildcards: phage_dbs.loc[wildcards.phage_db_id, "path"],
    output:
        temp("{phage_db_id}/chunks/split.done")
    params:
        splits = config["blastn"]["split"]
    resources: 
        cpus_per_task = 24,
        runtime = 7200,
        mem = "100GB"
    conda: "../envs/seqkit_env.yml"
    shell:
        """
        seqkit split {input.fasta} --by-part {params.splits} \
        --out-dir {wildcards.phage_db_id}/chunks --force -j {resources.cpus_per_task}
         
        for file in {wildcards.phage_db_id}/chunks/part_*.fasta; do
            # Extract the numeric part, removing leading zeros
            num=$(basename "$file" | sed -E 's/part_0*([0-9]+)\.fasta/\\1/')
        
            # Construct the new filename
            new_file="{wildcards.phage_db_id}/chunks/part_${{num}}.fasta"
        
            # Only rename if the filenames are different
            if [[ "$file" != "$new_file" ]]; then
                echo "Renaming: $file -> $new_file"
                mv "$file" "$new_file"
            else
                echo "Skip renaming: $file"
            fi
        done
        """

rule check_chunk:
    input:
        "{phage_db_id}/chunks/split.done"
    output:
        temp("{phage_db_id}/chunks/part_{chunk}.fasta")
    shell:
        """
        if [ -f {output} ]; then
            touch {output}
        else
            echo "Error: {output} does not exist." >&2
            exit 1
        fi
        """ 

