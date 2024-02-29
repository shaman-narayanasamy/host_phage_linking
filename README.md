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
(echo -e "ID\tpath" && paste <(realpath bacterial_genomes/assemblies/*/*/ncbi_dataset/data/*/*.fna | cut -f 9 -d '/') <(realpath bacterial_genomes/assemblies/*/*/ncbi_dataset/data/*/*.fna))  > all_host_genomes.tsv
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
