# Changelog

All notable changes to the Daytona Chikungunya pipeline will be documented in this file.

---

## [Unreleased]

Pre-1.0 development - initial Chikungunya virus (CHIKV) pipeline, adapted from the
`Daytona` (SARS-CoV-2) pipeline and in active testing before the first tagged release.

### Added

- `daytona_chikv.nf`: entry workflow; `meta`-driven, staged-file channel design
- `nextflow.config`: single config; per-tool `withName` `container`/`cpus`/`memory`;
  tool groups with identical settings share a regex selector (`fastqc.*`, `bbtools.*`,
  `samtools.*`, `ivar.*`); profiles for `standard`, `docker`, `singularity`, `apptainer`
- `modules/`: one `.nf` per tool: `fastqc`, `humanscrubber`, `trimmomatic`, `bbtools`,
  `kraken2`, `bwa`, `samtools` (`samtools_bam`/`samtools_coverage`/`samtools_mpileup`),
  `ivar` (`ivar_trim`/`ivar_variants`/`ivar_consensus`), `qc_gate`,
  `nextclade` (`nextclade_download`/`nextclade`), `summary_report`, `multiqc`
- `modules/multiqc.nf`: branded, interactive run-level dashboard
  (`output/daytona_chikv_report.html`) plus a per-sample `multiqc_sample` process over each
  sample's raw + clean FastQC (`output/<sample_id>/multiqc/`). The run-level process stages
  the config, CSS and custom tables, writes an inline Software Versions table from the
  container tags pinned in `nextflow.config`, and removes the `_mqc.tsv` files after each run
  so a resumed run does not re-ingest stale tables
- `modules/nextclade.nf`: Nextclade **v3** with
  `nextclade dataset get --name community/v-gen-lab/chikV/genotypes` (CHIKV genotype:
  ECSA / Asian / West African) and `storeDir` caching
- `bin/qc_gate.py`: QC gate (≥80% genome, ≥100x depth); 2-column TSV. On PASS it also copies
  the consensus to `<sample_id>.consensus.fasta`, which `qc_gate` publishes to
  `assemblies_qc_pass/`, the same directory `Daytona_dengue` and `Daytona` use. CHIKV has no
  VADR model, so `qc_flag` is this pipeline's assembly verdict
- `bin/summary_report.py`: aggregates per-sample stats into `summary_report.txt`;
  Kraken2 CHIKV percentage and Nextclade genotype/version.
  `_mqc_preamble`/`_write_mqc`/`emit_daytona_mqc_tables` write
  `daytona_chikv_genotype_mqc.tsv` and `daytona_chikv_assembly_mqc.tsv`, rendered as sortable,
  color-coded tables in the dashboard
- `assets/reference/chikv.reference.fasta`: CHIKV ECSA reference
  `hChikV_Angola_NIID_NIID54_2016` (11,237 bp; PrimalScheme reference)
- `assets/primers/CHIKV.primer.bed`: CHIKV tiling scheme (33 amplicons, 2 pools)
- `assets/annotations/CHIKV_LC259094.1_genomic.gff`: NCBI/DDBJ `LC259094.1` CDS
  features lifted onto the local reference (constant offset δ=76, 5'/3' UTRs trimmed):
  nonstructural polyprotein `1..7425`, structural polyprotein `7491..11237`; seqid
  renamed to `hChikV_Angola_NIID_NIID54_2016` so `ivar variants -g` annotates amino-acid changes
- `daytona_chikv.sh`: SLURM submission script (`module load conda apptainer nextflow`,
  `NXF_APPTAINER_CACHEDIR`, timestamp rename block)
- `README.md`, `CHANGELOG.md`, `LICENSE`
- `assets/multiqc_config.yaml` and `assets/daytona_chikv_report.css`: dashboard definition;
  branding, section order, column visibility and placement, and pass/fail cell coloring
- `modules/fastqc.nf`: the `fastqc` process symlinks its inputs to `<sample>_R{1,2}_raw.fastq.gz`
  before running, so raw and clean reads collapse onto one General Statistics row per sample
  instead of two. MultiQC keys FastQC rows off the `Filename` recorded inside `fastqc_data.txt`,
  which follows the input name, so renaming the output zip has no effect
- `.gitattributes` to enforce LF line endings

### Changed

- All 17 `publishDir` directives across `modules/*.nf` rewritten from bare-string to closure
  form (`publishDir { "..." }, mode: 'copy'`), required by the v2 strict script parser that
  Nextflow 26.04 makes the default. The bare-string form evaluates the path at
  process-definition time, before `meta` is in scope, raising `No such variable: meta` at
  module load. The pipeline now runs on Nextflow 23.04 through 26.x
- `daytona_chikv.nf`: the read channel gets `.ifEmpty { error(...) }`, so an input directory
  with no matching FASTQ files aborts immediately instead of exiting 0 having done nothing;
  `ch_barrier` gets `.ifEmpty(true)`, so a run where no sample reaches `nextclade` still
  triggers `summary_report` instead of stalling
- `bin/summary_report.py`: `percent_genome_cov_map` renamed to `percent_genome_cov_aligned`
  (breadth of coverage from the mapped BAM) and `percent_ref_genome_cov` renamed to
  `percent_genome_cov_assembled` (completeness of the final iVar consensus, the value
  `qc_flag` is thresholded on). These are the names `Daytona_dengue` uses
- `bin/summary_report.py`: exits nonzero when `samtools_coverage`, `ivar_consensus`, `qc_gate`
  or `nextclade` produced zero successful outputs across every sample that reached them. Those
  processes run under `errorStrategy = 'ignore'`, which otherwise reports a broken container,
  a missing reference or a bad mount the same way it reports one sample's low coverage
- `modules/summary_report.nf`: emits `*_mqc.tsv` on a channel and scopes `publishDir` to
  `summary_report.txt`, so the dashboard tables never land in the output directory
- `README.md`: Nextflow support range updated to 23.04-26.x; workflow diagram condensed into
  pipeline-stage categories; output section documents `daytona_chikv_report.html` and
  `assemblies_qc_pass/`
