rule collect_all_genomes:
    input:
        table = config["host_table"]
    output:
        all_hosts_dir = directory("all_host_genomes")
    shell:
        """
        mkdir -p {output.all_hosts_dir}
         
        grep -v "^#" {input.table} | tail -n+2 |  cut -f2 | xargs -I % ln -s % {output.all_hosts_dir}/
        """

rule viral_host_interaction_prediction:    
    input:
        blastn_hosts = "blast/{phage_db_id}/results/hosts/final_blast.tsv",
        blastn_spacers = "blast/{phage_db_id}/results/spacers/final_blast.tsv",
        virus_dir = "{phage_db_id}",
        host_dir = "all_host_genomes"
    output:
        predictions = "vhip/{phage_db_id}/predictions.tsv",
        donefile = "vhip/{phage_db_id}/vhip.done"
    params:
        vhip_script = "/home/naras0c/repositories/github/VirusHostInteractionPredictor/run_vhip.py",
        vhip_training_data = "/home/naras0c/repositories/github/VirusHostInteractionPredictor/data/ml_input.csv"
    resources:
        cpus_per_task = 48,
        mem = "250GB",
        runtime = 7200
    conda: "vhip"
    shell:
        """
        mkdir -p {tmp_dir}

        # Remove the header before parsing 
        tail -n +2 {input.blastn_hosts} > {tmp_dir}/blastn_hosts.tsv
        tail -n +2 {input.blastn_spacers} > {tmp_dir}/blastn_spacers.tsv
        
        {params.vhip_script} --virus_dir {input.virus_dir} --host_dir {input.host_dir} \
        --blastn {tmp_dir}/blastn_hosts.tsv --spacers {tmp_dir}/blastn_spacers.tsv \
        --ml_training {params.vhip_training_data} \
        --output {output.predictions} --cpu_cores {resources.cpus_per_task}

        touch {output.donefile}
        """
