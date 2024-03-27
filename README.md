## Download genomes
```{bash}
# Go to folder where the assemblies are to be stored
cd /ibex/user/naras0c/key_taxa_ww/bacterial_genomes/assemblies
# Iteratively download the genomes that are defined within the tables
for i in ../assembly_information/*_nonref.tsv; do /home/naras0c/repositories/github/key_taxa_ww/scripts/download_genomes.sh $i; done
```

## Prepare host tables
List of all host genome assemblies
```{bash}
 $ (echo -e "ID\tpath" && paste <(realpath /ibex/user/naras0c/key_taxa_ww/bacterial_genomes/assemblies/*/*/ncbi_dataset/data/*/*.fna | cut -f 9 -d '/') <(realpath /ibex/user/naras0c/key_taxa_ww/bacterial_genomes/assemblies/*/*/ncbi_dataset/data/*/*.fna)) | uniq > /ibex/user/naras0c/key_taxa_ww/all_host_genomes.tsv 
```
List of directories that separate genomes based on taxa of interest
```{bash}
(echo -e "ID\tpath" && paste <(realpath bacterial_genomes/assemblies/* | grep -v "tmp" | cut -f8 -d '/') <(realpath bacterial_genomes/assemblies/* | grep -v "tmp")) > all_host_taxa.tsv
```

## Launch workflow
```{bash}
/home/naras0c/repositories/github/key_taxa_ww/launchers/sbatch.sh --dry-run
```
```{bash}
nohup launchers/sbatch.sh > nohup_logs/sbatch_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```

## Execute markdown for automated curation of blastn results
For sludge bulking key taxa:
```{shell}
quarto render /Users/shaman.narayanasamy/Work/repositories/github/key_taxa_ww/scripts/curate_key_taxa_genomes.qmd --to html -P system_type=sb -o sb_output.html --output-dir render
```

For saltwater desalination biofilm key taxa:
```{shell}
quarto render /Users/shaman.narayanasamy/Work/repositories/github/key_taxa_ww/scripts/curate_key_taxa_genomes.qmd --to html -P system_type=swbd -o swbd_output.html --output-dir render
```

## Summarising data for analysis
### Summarise 16S sequences
The 16S sequences were a product of a separate analyses. They were  shared as
fasta files (with the extension `.txt`). Hence, we summarise the no. of sequences as follows:

```{sh}
grep -nc "^>" *.txt | sed -e 's/\.txt:/\t/g' | sed -e 's/__/\t/g' | sed -e 's/_/\t/g'
```
## Collect data for analysis (on ibex)
Create a folder to store all the summary data:
```{sh}
cd /ibex/user/naras0c/key_taxa_ww/output
mkdir -p summary_data
```

Obtain all the fasta IDs of the phages:
```{sh}
$ find /ibex/user/naras0c/key_taxa_ww/output/phage_databases -type f -name "*.gz" -print0 | xargs -0 -I{} sh -c 'zcat {} | grep "^>" | sed "s~^~{}: ~"' | sed -e 's/: >/\t/g' > summary_data/phage_fastaFilename2fastaID.tsv
```

Compile spacepharere (CRISPR-spacer matching) data:
```{sh}
cat spacepharer/*/predictions.tsv | grep -v "^#" > summary_data/spacepharer_spacer_alignment_results.tsv
```

```{sh}
cat spacepharer/*/predictions.tsv | \grep "^#" | sed -e 's/^#//g' > summary_data/spacepharer_host_results.tsv
```

Collect CRISPR-Cas information for the the key taxa genomes:

```{sh}
grep -H "####Summary" host_crisprcasfinder/GC*/*/TSV/Cas_REPORT.tsv | sed -e 's/:####/\t/' | sed -e 's:host_crisprcasfinder/::g' | sed -e 's:/:\t:' | sed -s 's/:/\t/g' | cut -f 1,6 | awk -v OFS="\t" '{
    printf "%s\t", $1;  # Print the file identifier with a trailing tab
    $1="";  # Remove the file identifier from the line
    gsub(/\[|\]/, "");  # Remove brackets
    gsub(/\([^)]+\)/, "");  # Remove content within parentheses
    gsub(/.*####Summary system CAS:.*: \[|\].*/, "");  # Strip leading and trailing parts (if still needed)
    n = gsub(/cas[[:digit:]]+_Type[[:alnum:]_]+/, "&");  # Keep casX_TypeY patterns
    gsub(/; /, OFS);  # Replace "; " with a tab
    gsub(/;/, "");  # Remove remaining semicolons
    print;  # Print the modified line
}' > summary_data/crisprcasfinder_host_results.tsv
```
