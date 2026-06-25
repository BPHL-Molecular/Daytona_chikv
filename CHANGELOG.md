# Changelog

All notable changes to the Daytona Chikungunya pipeline will be documented in this file.

---

## [1.0.0] - initial release

Initial Chikungunya virus (CHIKV) pipeline, adapted from the `Daytona` (SARS-CoV-2)
pipeline.

### Added

- `daytona_chikv.nf`: entry workflow; `meta`-driven, staged-file channel design
- `nextflow.config`: single config; per-tool `withName` `container`/`cpus`/`memory`;
  profiles for `standard`, `docker`, `singularity`, `apptainer`
- `modules/`: one `.nf` per tool: `fastqc`, `humanscrubber`, `trimmomatic`, `bbtools`,
  `multiqc`, `kraken2`, `bwa`, `samtools` (`samtools_bam`/`samtools_coverage`/`samtools_mpileup`),
  `ivar` (`ivar_trim`/`ivar_variants`/`ivar_consensus`), `qc_gate`,
  `nextclade` (`nextclade_download`/`nextclade`), `summary_report`
- `modules/nextclade.nf`: Nextclade **v3** with
  `nextclade dataset get --name community/v-gen-lab/chikV/genotypes` (CHIKV genotype
  assignment: ECSA / Asian / West African) and `storeDir` caching
- `bin/qc_gate.py`: QC gate (≥80% genome, ≥100x depth); 2-column TSV
- `bin/summary_report.py`: aggregates per-sample stats into `summary_report.txt`;
  Kraken2 CHIKV percentage and Nextclade genotype/version
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
