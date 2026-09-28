import os

def crispr_output_dir(wildcards, input):
    fasta_basename = os.path.basename(input[0]).replace(".fna", "")
    return f"host_crisprcasfinder/{fasta_basename}"

def rawcrisprs_out(wildcards, input):
    return os.path.join(crispr_output_dir(wildcards, input), "rawCRISPRs.fna")

def resultjson_out(wildcards, input):
    return os.path.join(crispr_output_dir(wildcards, input), "result.json")


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

       cp {input.host_fasta} {wildcards.host_id}.fasta
       
       mkdir -p {tmp_dir}

       {params.executor} {wildcards.host_id}.fasta ./{params.outdir} {tmp_dir}/{wildcards.host_id} {resources.cpus_per_task} 
       
       # Ensure rawCRISPRs.fna exists, even if empty

       if [[ -e "{output.rawCRISPRs}" ]]; then
           echo "File exists!"
       else
           echo "File does not exist!"
           touch {output.rawCRISPRs}
       fi

       rm -f {wildcards.host_id}.fasta
       """
