rule crisprcasfinder:
    input:
        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
    output:
        output = directory("host_crisprcasfinder/{host_id}")
    params: 
        executor = config["crisprcasfinder"]["executor_script_path"],
        threads = config["crisprcasfinder"]["threads"],
    benchmark: "host_crisprcasfinder/benchmarks/{host_id}.txt"
    log: "host_crisprcasfinder/logs/{host_id}.txt"
    shell:
       """
       {params.executor} {input.host_fasta} {output} {params.threads}
       """
