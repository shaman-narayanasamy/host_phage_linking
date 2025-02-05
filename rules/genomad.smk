rule genomad:
    input:
        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
    output:
        annotate_outdir = directory("genomad/{host_id}/annotate"),
        provirus_outdir = directory("genomad/{host_id}/provirus")
    params:
        db = config["genomad"]["db"],
    resources:
        cpus_per_task = 24,
        mem = "100GB",
        time = 7200
    conda: "../envs/genomad_env.yml"
    benchmark: "host_genomad/benchmarks/{host_id}.txt"
    log: "host_genomad/logs/{host_id}.txt"
    shell:
       """
       genomad annotate {input.host_fasta} \
       {output.annotate_outdir} {params.db} \
       --conservative-taxonomy --threads {resources.cpus_per_task} \
       --restart --cleanup
       
       genomad find-proviruses {output.annotate_outdir} \
       {output.provirus_outdir} {params.db} \
       --threads {resources.cpus_per_task} \
       --restart --cleanup
       """
