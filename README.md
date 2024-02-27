## Download genomes
```{bash}
# Go to folder where the assemblies are to be stored
cd /ibex/user/naras0c/key_taxa_ww/bacterial_genomes/assemblies
# Iteratively download the genomes that are defined within the tables
for i in ../assembly_information/*_nonref.tsv; do /home/naras0c/repositories/github/key_taxa_ww/scripts/download_genomes.sh $i; done
````
## Launch workflow
```{bash}
/home/naras0c/repositories/github/key_taxa_ww/launchers/sbatch.sh --dry-run
```
