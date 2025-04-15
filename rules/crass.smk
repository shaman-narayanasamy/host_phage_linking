rule crass_contigs:    
    input:
        assembly = get_assembly_path
    output:
        outfile = "{sample}/crass_contigs_out/crass.crispr",
        spacers = "{sample}/crass_contigs_out/spacers.fa",
        repeats = "{sample}/crass_contigs_out/repeats.fa",
        flanks = "{sample}/crass_contigs_out/flanks.fa"
    resources:
        runtime = 1440,
        mem = "60GB"
    group: "crass"
    conda: "../../envs/crass_env.yml"
    benchmark: "{sample}/benchmarks/crass_contigs.txt"
    log: "{sample}/logs/crass_contigs.txt"
    shell:
        """
        crass -o {wildcards.sample}/crass_contigs_out {input}
        
        crisprtools extract -H {wildcards.sample}:contigs: \
        -o {wildcards.sample}/crass_contigs_out \
        -sspacers.fa -drepeats.fa -fflanks.fa {output.outfile}  
        
        dir="{wildcards.sample}/crass_contigs_out"
        
        mv $dir/{wildcards.sample}:contigs:spacers.fa $dir/spacers.fa
        mv $dir/{wildcards.sample}:contigs:repeats.fa $dir/repeats.fa
        mv $dir/{wildcards.sample}:contigs:flanks.fa $dir/flanks.fa
        """

