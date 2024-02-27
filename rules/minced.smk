rule minced:
    input:
        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
    output:
        output = "host_minced/{host_id}.txt"
    conda: "../envs/minced_env.yml"
    benchmark: "host_minced/benchmarks/{host_id}.txt"
    log: "host_minced/logs/{host_id}.txt"
    shell:
        """ 
        mkdir -p host_mince
        minced {input.host_fasta} {output}
        """
