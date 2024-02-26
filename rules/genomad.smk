rule genomad:
    input:
        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
    output:
        output = directory("host_genomad/{host_id}")
    params:
        db = config["genomad"]["db"],
        threads = config["genomad"]["threads"]
    conda: "../envs/genomad_env.yml"
    benchmark: "host_genomad/benchmarks/{host_id}.txt"
    log: "host_genomad/logs/{host_id}.txt"
    shell:
       """
       genomad end-to-end -t {params.threads} \
       --cleanup --restart {input.host_fasta} {output} {params.db}
       """
