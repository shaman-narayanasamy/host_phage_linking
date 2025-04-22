#    input:
#        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
        #host_fasta = lambda wildcards: print(f"DEBUG: host_id = {wildcards.host_id}") or hosts.loc[wildcards.host_id, "path"],

rule crisprcasfinder:
    input:
        host_fasta = lambda wildcards: hosts.loc[wildcards.host_id, "path"],
    output:
        output = "host_crisprcasfinder/{host_id}/result.json",
        rawCRISPRs = "host_crisprcasfinder/{host_id}/rawCRISPRs.fna"
    resources: 
        cpus_per_task = 4,
        runtime = 2880,
        mem = "120GB"
    params:
        executor = config["crisprcasfinder"]["executor_script_path"],
        outdir = "host_crisprcasfinder"
    benchmark: "host_crisprcasfinder/benchmarks/{host_id}.txt"
    log: "host_crisprcasfinder/logs/{host_id}.txt"
    shell:
       """
       # Need to remove the output directory as it will not overwrite
       rm -rf {params.outdir}/{wildcards.host_id}
       
       mkdir -p {tmp_dir}

       {params.executor} {input.host_fasta} ./{params.outdir} {tmp_dir}/{wildcards.host_id} {resources.cpus_per_task} 
       
       
       # Ensure rawCRISPRs.fna exists, even if empty

       if [[ -e {output.rawCRISPRs} ]]; then
           echo "File exists!"
       else
           echo "File does not exist!"
           touch {output.rawCRISPRs}
       fi
       """

#       mv {params.outdir}/{wildcards.host_id}/{wildcards.host_id}/* {params.outdir}/{wildcards.host_id}
#       rm -rf {params.outdir}/{wildcards.host_id}/{wildcards.host_id}

