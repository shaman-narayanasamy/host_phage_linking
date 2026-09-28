rule pilercr:
    input:
        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
    output:
        output = "host_pilercr/{host_id}.out"
    conda: "../envs/pilercr_env.yml"
    resources: 
        cpus_per_task = 12,
        runtime = 1440,
        mem = "48GB"
    benchmark: "host_pilercr/benchmarks/{host_id}.txt"
    log: "host_pilercr/logs/{host_id}.txt"
    shell:
        """ 
        mkdir -p host_pilercr
        pilercr -noinfo -quiet -in {input.host_fasta} -out {output}
        """
