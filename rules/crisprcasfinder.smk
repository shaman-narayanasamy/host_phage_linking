rule crisprcasfinder:
    input:
        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
    output:
        output = "host_crisprcasfinder/{host_id}/{host_id}/rawCRISPRs.fna"
    resources: 
        cpus_per_task = 4,
        runtime = 2880,
        mem = "120GB"
    params:
        executor = config["crisprcasfinder"]["executor_script_path"]
    benchmark: "host_crisprcasfinder/benchmarks/{host_id}.txt"
    log: "host_crisprcasfinder/logs/{host_id}.txt"
    shell:
       """
       {params.executor} {input.host_fasta} {output} {resources.cpus_per_task}
       """
