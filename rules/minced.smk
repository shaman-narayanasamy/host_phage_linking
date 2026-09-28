rule minced:
    input:
        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
    output:
        output = "host_minced/{host_id}.txt"
    resources:
        cpus_per_task = 1,
        mem = 40000,
        time = 2880
    conda: "../envs/minced_env.yml"
    benchmark: "host_minced/benchmarks/{host_id}.txt"
    log: "host_minced/logs/{host_id}.txt"
    shell:
        """ 
        mkdir -p host_minced
        minced {input.host_fasta} {output}
        """
