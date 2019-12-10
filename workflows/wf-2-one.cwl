#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  one_genome: Directory[]

outputs:
  one_genome_result:
    type: Directory[]
    outputSource: process_one_genome/cluster_folder

  prokka_cat_one:
    type: File
    outputSource: concatenate/result

steps:

# ----------- << one genome cluster processing >> -----------
  process_one_genome:
    run: sub-wf/sub-wf-one-genome.cwl
    scatter: cluster
    in:
      cluster: one_genome
    out:
      - prokka_faa-s
      - cluster_folder

# ----------- << prep mmseqs >> -----------

  flatten_one:
   run: ../utils/flatten_array.cwl
   in:
     arrayTwoDim: process_one_genome/prokka_faa-s
   out: [array1d]

  concatenate:
    run: ../utils/concatenate.cwl
    in:
      files: flatten_one/array1d
      outputFileName: { default: 'prokka_one.fa' }
    out: [ result ]
