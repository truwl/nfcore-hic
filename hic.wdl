version 1.0

workflow hic {
	input{
		File samplesheet
		String input_paths = "undefined"
		String outdir = "./results"
		String? email
		String? genome
		File? fasta
		String igenomes_base = "s3://ngi-igenomes/igenomes"
		Boolean? igenomes_ignore
		String? bwt2_index
		String digestion = "hindiii"
		String restriction_site = "'A^AGCTT'"
		String ligation_site = "'AAGCTAGCTT"
		String? chromosome_size
		String? restriction_fragments
		Boolean? save_reference
		Boolean? save_nonvalid_pairs
		Boolean? dnase
		Int? min_cis_dist
		Boolean? split_fastq
		Int fastq_chunks_size = 20000000
		Int min_mapq = 10
		String bwt2_opts_end2end = "'--very-sensitive -L 30 --score-min L,-0.6,-0.2 --end-to-end --reorder'"
		String bwt2_opts_trimmed = "'--very-sensitive -L 20 --score-min L,-0.6,-0.2 --end-to-end --reorder'"
		Boolean? save_aligned_intermediates
		Boolean? keep_dups
		Boolean? keep_multi
		Int? max_insert_size
		Int? min_insert_size
		Int? max_restriction_fragment_size
		Int? min_restriction_fragment_size
		Boolean? save_interaction_bam
		String bin_size = "1000000,500000"
		Boolean? hicpro_maps
		Float ice_filter_low_count_perc = 0.02
		Int? ice_filter_high_count_perc
		Float ice_eps = 0.1
		Int ice_max_iter = 100
		String res_zoomify = "5000"
		String res_dist_decay = "1000000"
		String tads_caller = "hicexplorer,insulation"
		String res_tads = "40000,20000"
		String res_compartments = "250000"
		Boolean? skip_maps
		Boolean? skip_dist_decay
		Boolean? skip_tads
		String? skip_compartments
		Boolean? skip_balancing
		Boolean? skip_mcool
		Boolean? skip_multiqc
		Boolean? help
		String publish_dir_mode = "copy"
		Boolean validate_params = true
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean? show_hidden_params
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			samplesheet = samplesheet,
			input_paths = input_paths,
			outdir = outdir,
			email = email,
			genome = genome,
			fasta = fasta,
			igenomes_base = igenomes_base,
			igenomes_ignore = igenomes_ignore,
			bwt2_index = bwt2_index,
			digestion = digestion,
			restriction_site = restriction_site,
			ligation_site = ligation_site,
			chromosome_size = chromosome_size,
			restriction_fragments = restriction_fragments,
			save_reference = save_reference,
			save_nonvalid_pairs = save_nonvalid_pairs,
			dnase = dnase,
			min_cis_dist = min_cis_dist,
			split_fastq = split_fastq,
			fastq_chunks_size = fastq_chunks_size,
			min_mapq = min_mapq,
			bwt2_opts_end2end = bwt2_opts_end2end,
			bwt2_opts_trimmed = bwt2_opts_trimmed,
			save_aligned_intermediates = save_aligned_intermediates,
			keep_dups = keep_dups,
			keep_multi = keep_multi,
			max_insert_size = max_insert_size,
			min_insert_size = min_insert_size,
			max_restriction_fragment_size = max_restriction_fragment_size,
			min_restriction_fragment_size = min_restriction_fragment_size,
			save_interaction_bam = save_interaction_bam,
			bin_size = bin_size,
			hicpro_maps = hicpro_maps,
			ice_filter_low_count_perc = ice_filter_low_count_perc,
			ice_filter_high_count_perc = ice_filter_high_count_perc,
			ice_eps = ice_eps,
			ice_max_iter = ice_max_iter,
			res_zoomify = res_zoomify,
			res_dist_decay = res_dist_decay,
			tads_caller = tads_caller,
			res_tads = res_tads,
			res_compartments = res_compartments,
			skip_maps = skip_maps,
			skip_dist_decay = skip_dist_decay,
			skip_tads = skip_tads,
			skip_compartments = skip_compartments,
			skip_balancing = skip_balancing,
			skip_mcool = skip_mcool,
			skip_multiqc = skip_multiqc,
			help = help,
			publish_dir_mode = publish_dir_mode,
			validate_params = validate_params,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			max_multiqc_email_size = max_multiqc_email_size,
			monochrome_logs = monochrome_logs,
			multiqc_config = multiqc_config,
			tracedir = tracedir,
			show_hidden_params = show_hidden_params,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			custom_config_version = custom_config_version,
			custom_config_base = custom_config_base,
			hostnames = hostnames,
			config_profile_name = config_profile_name,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-hic/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		File samplesheet
		String input_paths = "undefined"
		String outdir = "./results"
		String? email
		String? genome
		File? fasta
		String igenomes_base = "s3://ngi-igenomes/igenomes"
		Boolean? igenomes_ignore
		String? bwt2_index
		String digestion = "hindiii"
		String restriction_site = "'A^AGCTT'"
		String ligation_site = "'AAGCTAGCTT"
		String? chromosome_size
		String? restriction_fragments
		Boolean? save_reference
		Boolean? save_nonvalid_pairs
		Boolean? dnase
		Int? min_cis_dist
		Boolean? split_fastq
		Int fastq_chunks_size = 20000000
		Int min_mapq = 10
		String bwt2_opts_end2end = "'--very-sensitive -L 30 --score-min L,-0.6,-0.2 --end-to-end --reorder'"
		String bwt2_opts_trimmed = "'--very-sensitive -L 20 --score-min L,-0.6,-0.2 --end-to-end --reorder'"
		Boolean? save_aligned_intermediates
		Boolean? keep_dups
		Boolean? keep_multi
		Int? max_insert_size
		Int? min_insert_size
		Int? max_restriction_fragment_size
		Int? min_restriction_fragment_size
		Boolean? save_interaction_bam
		String bin_size = "1000000,500000"
		Boolean? hicpro_maps
		Float ice_filter_low_count_perc = 0.02
		Int? ice_filter_high_count_perc
		Float ice_eps = 0.1
		Int ice_max_iter = 100
		String res_zoomify = "5000"
		String res_dist_decay = "1000000"
		String tads_caller = "hicexplorer,insulation"
		String res_tads = "40000,20000"
		String res_compartments = "250000"
		Boolean? skip_maps
		Boolean? skip_dist_decay
		Boolean? skip_tads
		String? skip_compartments
		Boolean? skip_balancing
		Boolean? skip_mcool
		Boolean? skip_multiqc
		Boolean? help
		String publish_dir_mode = "copy"
		Boolean validate_params = true
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean? show_hidden_params
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? hostnames
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /hic-1.3.0  -profile truwl  --input ~{samplesheet} 	~{"--samplesheet " + samplesheet}	~{"--input_paths " + input_paths}	~{"--outdir " + outdir}	~{"--email " + email}	~{"--genome " + genome}	~{"--fasta " + fasta}	~{"--igenomes_base " + igenomes_base}	~{true="--igenomes_ignore  " false="" igenomes_ignore}	~{"--bwt2_index " + bwt2_index}	~{"--digestion " + digestion}	~{"--restriction_site " + restriction_site}	~{"--ligation_site " + ligation_site}	~{"--chromosome_size " + chromosome_size}	~{"--restriction_fragments " + restriction_fragments}	~{true="--save_reference  " false="" save_reference}	~{true="--save_nonvalid_pairs  " false="" save_nonvalid_pairs}	~{true="--dnase  " false="" dnase}	~{"--min_cis_dist " + min_cis_dist}	~{true="--split_fastq  " false="" split_fastq}	~{"--fastq_chunks_size " + fastq_chunks_size}	~{"--min_mapq " + min_mapq}	~{"--bwt2_opts_end2end " + bwt2_opts_end2end}	~{"--bwt2_opts_trimmed " + bwt2_opts_trimmed}	~{true="--save_aligned_intermediates  " false="" save_aligned_intermediates}	~{true="--keep_dups  " false="" keep_dups}	~{true="--keep_multi  " false="" keep_multi}	~{"--max_insert_size " + max_insert_size}	~{"--min_insert_size " + min_insert_size}	~{"--max_restriction_fragment_size " + max_restriction_fragment_size}	~{"--min_restriction_fragment_size " + min_restriction_fragment_size}	~{true="--save_interaction_bam  " false="" save_interaction_bam}	~{"--bin_size " + bin_size}	~{true="--hicpro_maps  " false="" hicpro_maps}	~{"--ice_filter_low_count_perc " + ice_filter_low_count_perc}	~{"--ice_filter_high_count_perc " + ice_filter_high_count_perc}	~{"--ice_eps " + ice_eps}	~{"--ice_max_iter " + ice_max_iter}	~{"--res_zoomify " + res_zoomify}	~{"--res_dist_decay " + res_dist_decay}	~{"--tads_caller " + tads_caller}	~{"--res_tads " + res_tads}	~{"--res_compartments " + res_compartments}	~{true="--skip_maps  " false="" skip_maps}	~{true="--skip_dist_decay  " false="" skip_dist_decay}	~{true="--skip_tads  " false="" skip_tads}	~{"--skip_compartments " + skip_compartments}	~{true="--skip_balancing  " false="" skip_balancing}	~{true="--skip_mcool  " false="" skip_mcool}	~{true="--skip_multiqc  " false="" skip_multiqc}	~{true="--help  " false="" help}	~{"--publish_dir_mode " + publish_dir_mode}	~{true="--validate_params  " false="" validate_params}	~{"--email_on_fail " + email_on_fail}	~{true="--plaintext_email  " false="" plaintext_email}	~{"--max_multiqc_email_size " + max_multiqc_email_size}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--multiqc_config " + multiqc_config}	~{"--tracedir " + tracedir}	~{true="--show_hidden_params  " false="" show_hidden_params}	~{"--max_cpus " + max_cpus}	~{"--max_memory " + max_memory}	~{"--max_time " + max_time}	~{"--custom_config_version " + custom_config_version}	~{"--custom_config_base " + custom_config_base}	~{"--hostnames " + hostnames}	~{"--config_profile_name " + config_profile_name}	~{"--config_profile_description " + config_profile_description}	~{"--config_profile_contact " + config_profile_contact}	~{"--config_profile_url " + config_profile_url}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-hic:1.3.0_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    