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
       genomad annotate --input {input.host_fasta} --restart \
       --output {output.annotate_outdir} --database {params.db} \
       --conservative-taxonomy --threads {resources.cpus_per_task} \
       --restart --cleanup
       
       genomad find-proviruses --input {output.annotate_outdir} \
       --output {output.provirus_outdir} --threads {resources.cpus_per_task} \
       --restart --cleanup
       """

#       genomad end-to-end -t {params.threads} \
#       --cleanup --restart {input.host_fasta} {output} {params.db}


