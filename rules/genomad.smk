rule genomad:
    input:
        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
    output:
        json = "host_genomad/{host_id}/genomic_find_proviruses/genomic_find_proviruses.json"
    params:
        db = config["genomad"]["db"],
        outdir = "host_genomad/{host_id}"
    resources:
        cpus_per_task = 24,
        mem = "100GB",
        time = 7200
    conda: "../envs/genomad_env.yml"
    benchmark: "host_genomad/benchmarks/{host_id}.txt"
    log: "host_genomad/logs/{host_id}.txt"
    shell:
       """
       mkdir -p {params.outdir}
       
       cp {input.host_fasta} {params.outdir}/genomic.fa

       genomad annotate {params.outdir}/genomic.fa \
       {params.outdir} {params.db}/ \
       --conservative-taxonomy --threads {resources.cpus_per_task} \
       --restart --cleanup
       
       genomad find-proviruses {params.outdir}/genomic.fa \
       {params.outdir} {params.db} \
       --threads {resources.cpus_per_task} \
       --restart --cleanup
       """
