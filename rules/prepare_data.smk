# The software requires the phages and hosts to be in individual fasta files.
# Typically, bacterial genomes already exist as individual fasta files, but
# phage genomes, especially from newer databases, are grouped into a
# multi-fasta file, which needs to be split.

rule split_fasta:
    input:
        multi_fasta = lambda wildcards: phage_dbs.loc[wildcards.phage_db_id, "path"],
    output:
        output_dir = directory("phage_databases/{phage_db_id}"),
    shell:
         """
         if [ -d {input.multi_fasta} ]; then
             echo "{input.multi_fasta} is already a folder likely with multiple fasta files."
             echo "Creating soft link for {output.output_dir}"
             ln -s $(realpath {input.multi_fasta}) $(realpath {output.output_dir})
         else
             mkdir -p {output.output_dir} 
             grep "^>" /ibex/user/naras0c/virus_databases/RVMT_Zenodo_V4/Expanded_Contig_Set/Reference_Set/RV20/rv20.e.all005.fasta | \
             head -n 5 | \
             while IFS= read -r line; do \
             echo "$line"; 
             outfile_name=$(echo "$line" | sed -e 's/ /_/g' | sed -e 's/^>//g'); 
             pullseq -i /ibex/user/naras0c/virus_databases/RVMT_Zenodo_V4/Expanded_Contig_Set/Reference_Set/RV20/rv20.e.all005.fasta \
             -n $line | gzip > ${outfile_name}.gz; 
             done
         fi
         """
#         if [ -d {input.multi_fasta} ]; then
#             echo "{input.multi_fasta} is already a folder likely with multiple fasta files."
#             echo "Creating soft link for {output.output_dir}"
#             ln -s $(realpath {input.multi_fasta}) $(realpath {output.output_dir})
#         else
#             mkdir -p {output.output_dir} 
#             awk '/^>/{{if(x>0) close(out); \
#             x++; out=sprintf("gzip > {output.output_dir}/%s.fna.gz", substr($0,2)); print | out; \
#             next}} {{print | out}}' {input.multi_fasta}
#         fi

