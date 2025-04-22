rule spacepharer_prepare_db_spacers:
    input:
        multi_fasta = config["spacers_fasta"]
    output:
        temp("spacepharer/dbs/spacers/spacepharer_db.done")
    params: 
        output_dir = directory(os.path.join("spacepharer", "dbs", "spacers", "setDbs"))
    conda: "../envs/spacepharer_env.yml"
    resources:
        cpus_per_task = 40,
        mem = "120GB",
        runtime = 7200
    benchmark: "spacepharer/dbs/benchmarks/spacers_create_spacepharer_db.txt"
    log: "spacepharer/dbs/logs/spacers_create_spacepharer_db.log"
    shell:
         """
         rm -rf {params.output_dir}
         rm -rf {tmp_dir}/spacers/tmpFolder
          
         mkdir -p {params.output_dir}
         mkdir -p {tmp_dir}/spacers/tmpFolder
          
         spacepharer createsetdb {input.multi_fasta} \
         {params.output_dir}/querySetDb {tmp_dir}/spacers/tmpFolder \
         --threads {resources.cpus_per_task} 
         
         touch {output}
         """
