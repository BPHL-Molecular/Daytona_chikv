# Daytona Chikungunya

<p align="center">
  <em>⚠️ For research use only. Results were obtained by procedures that were not CLIA validated.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Pipeline-Daytona_Chikungunya-blue?style=plastic" />
  <img src="https://img.shields.io/badge/Nextflow-≥23.04-brightgreen?style=plastic&logo=nextflow" />
  <img src="https://img.shields.io/badge/Python-3.10+-yellow?style=plastic&logo=python" />
  <img src="https://img.shields.io/badge/License-MIT-red?style=plastic" />
</p>

## 🦟🧬 Overview

Daytona Chikungunya is Florida BPHL's Nextflow pipeline for Chikungunya virus (CHIKV) NGS data analysis. It processes paired-end Illumina reads through human read removal, quality control, adapter trimming, reference-based assembly, variant calling and genotype assignment.

Reads are aligned to the CHIKV ECSA reference `hChikV_Angola_NIID_NIID54_2016` (the PrimalScheme reference, derived from GenBank `LC259094.1`) and primer-trimmed against the CHIKV tiling amplicon scheme (33 amplicons, two pools). [Nextclade](https://github.com/nextstrain/nextclade) assigns the CHIKV genotype (ECSA, Asian, or West African) using the `community/v-gen-lab/chikV/genotypes` dataset.

> **Note on VADR:** Unlike `Daytona` (SARS-CoV-2) and `Daytona_dengue`, this pipeline does **not** run VADR. CHIKV is an *alphavirus* (family *Togaviridae*), and VADR ships no Togaviridae model, only flaviviruses (dengue/Zika/WNV), coronaviruses, caliciviruses, influenza, mpox and RSV. GenBank-submission validation is therefore out of scope for v1.

### ⚙️ Dependencies

- **Nextflow** 23.04-26.x - [installation guide](https://github.com/nextflow-io/nextflow)
- **Apptainer/Singularity** - [installation guide](https://apptainer.org/docs/user/latest/)
- **Conda** - [installation guide](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)
- **SLURM** workload manager (required for HiPerGator; otherwise not required)

All bioinformatics tools run inside containers, no additional software installation is required.

### 💻 Resource Requirements

Daytona Chikungunya is designed to run on an HPC environment but can run locally with sufficient resources.

- **CPUs:** 24 recommended; minimum 8
- **RAM:** 50 GB recommended; minimum 16 GB
- **Disk:** ~2-3 GB per sample (input + output)

### 🛠️ Setup

#### 1. Clone this repository and enter the repository directory

```bash
$ git clone https://github.com/BPHL-Molecular/Daytona_chikv

$ cd Daytona_chikv/
```

#### 2. Create the conda environment

```bash
$ conda create -n daytona_chikv -c conda-forge python=3.10
```

#### 2. Configure params.yaml

Edit `params.yaml` and set the input and output paths for your run:

```yaml
input:  "/full/path/to/fastqs"
output: "/full/path/to/output"
```

Both `input` and `output` must be absolute paths with no trailing slash.

#### 3. Configure daytona_chikv.sh

> At Florida BPHL we use **Apptainer** on HiPerGator for containerization. `daytona_chikv.sh` is pre-configured for SLURM + Apptainer and is the recommended submission method for HiPerGator users.

Add your email address for job notifications and set `NXF_APPTAINER_CACHEDIR` to your Apptainer image cache directory:

```bash
#SBATCH --mail-user=your@email.gov
export NXF_APPTAINER_CACHEDIR=/path/to/apptainer/cache
```

### How to Run

Place paired FASTQ files in the directory specified by `params.input`. Both Illumina native (`SAMPLE_S1_L001_R1_001.fastq.gz`) and simplified (`SAMPLE_1.fastq.gz`) naming conventions are supported. If no matching FASTQ files are found, the pipeline exits immediately with an error.

### 🐊 HiPerGator Usage

```bash
sbatch daytona_chikv.sh
```

### ⚡ Local Usage

```bash
# Apptainer/Singularity
nextflow run daytona_chikv.nf -profile apptainer -params-file params.yaml
```

### Workflow Diagram

```mermaid
flowchart LR
    IN[Paired FASTQ] --> QC["Read QC and cleaning<br/>FastQC · Human Scrubber · Trimmomatic · BBTools"]
    QC --> SCR["Taxonomic screen and alignment<br/>Kraken2 · BWA · Samtools"]
    SCR --> ASM["Assembly<br/>Samtools · iVar"]
    ASM --> VAL["Coverage QC and genotype assignment<br/>QC Gate · Nextclade"]

    QC --> REP[summary_report]
    SCR --> REP
    ASM --> REP
    VAL --> REP

    VAL --> AQP[assemblies_qc_pass/]
    REP --> OUT[summary_report.txt]
    REP --> DASH[daytona_chikv_report.html]

    style VAL fill:#9f9,stroke:#333,color:#000
    style REP fill:#f96,stroke:#333,stroke-width:2px,color:#000
    style OUT fill:#f96,stroke:#333,color:#000
    style DASH fill:#f96,stroke:#333,color:#000
    style AQP fill:#f96,stroke:#333,color:#000
```

> **QC GATE:** The **QC GATE** (`qc_flag`) is a minimum genome-breadth and read-depth check (≥80% genome covered, mean depth ≥100×). Because CHIKV has no VADR model, this is also the pipeline's assembly verdict: the QC gate copies every PASS consensus into `assemblies_qc_pass/`. Nextclade runs on **every** consensus, so a below-threshold genome still receives a genotype call; it just carries `qc_flag = FAIL`.

### 🧩 Modules

Daytona Chikungunya is made possible thanks to the following tools:

<small>

**Quality Control**: [FastQC](https://github.com/s-andrews/FastQC) 0.12.1 · [Trimmomatic](https://github.com/usadellab/Trimmomatic) 0.40 · [BBTools](https://github.com/bbushnell/BBTools) 39.84 · [MultiQC](https://github.com/MultiQC/MultiQC) 1.34

**Human Read Removal**: [NCBI SRA Human Scrubber](https://github.com/ncbi/sra-human-scrubber) 2.2.1

**Taxonomic Classification**: [Kraken2](https://github.com/DerrickWood/kraken2) 2.17.1 (viral)

**Reference-Based Assembly**: [BWA](https://github.com/lh3/bwa) 0.7.19 · [Samtools](https://github.com/samtools/samtools) 1.23.1 · [iVar](https://github.com/andersen-lab/ivar) 1.4.4

**Genotype Assignment**: [Nextclade](https://github.com/nextstrain/nextclade) 3.21.2 (`community/v-gen-lab/chikV/genotypes` dataset)

</small>

### 🧬 Reference & primer provenance

| Asset | Value |
|-------|-------|
| Reference | `hChikV_Angola_NIID_NIID54_2016` (CHIKV ECSA, 11,237 bp); PrimalScheme reference, = GenBank `LC259094.1`[77..11313] (UTRs trimmed) |
| Primers | CHIKV tiling scheme, 33 amplicons / 2 pools (ARTIC bed v3.0) |
| Annotation | `assets/annotations/CHIKV_LC259094.1_genomic.gff`: NCBI/DDBJ `LC259094.1` CDS features lifted onto the local reference (nonstructural `1..7425`, structural `7491..11237`) for `ivar variants -g` amino-acid annotation |
| Genotype dataset | Nextclade `community/v-gen-lab/chikV/genotypes` (reference `NC_004162.2` S27; ECSA / Asian / West African) |

### 📁 Output

Per-sample results are written to `params.output/<sample_id>/`. A single summary file is written to `params.output/`:

```markdown
output/
├── <sample_id>/
│   ├── fastqc/
│   ├── fastqc_clean/
│   ├── humanscrubber/
│   ├── trimmomatic/
│   ├── bbtools/
│   ├── kraken2/
│   ├── samtools/
│   ├── ivar/
│   ├── nextclade/
│   └── multiqc/
├── assemblies_qc_pass/
├── daytona_chikv_report.html
└── summary_report.txt
```

| File | Samples | Key fields |
|------|---------|------------|
| `summary_report.txt` | All | sample_id · reference · coverage stats · assembly stats · qc_flag · kraken2_percent · nextclade_clade · nextclade_version |
| `daytona_chikv_report.html` | All | Interactive dashboard: genotype and coverage QC, assembly QC, raw and clean FastQC, software versions |
| `assemblies_qc_pass/<sample_id>.consensus.fasta` | QC PASS only | Consensus sequences that cleared the QC gate |
| `<sample_id>/multiqc/<sample_id>_multiqc_report.html` | Per sample | Raw + clean FastQC for that sample |

### 🤝 Contributing

We welcome contributions to make Daytona Chikungunya better! Feel free to open issues or submit pull requests to suggest additional features or enhancements.

### 📧 Contact

**Email**: [bphl-sebioinformatics@flhealth.gov](mailto:bphl-sebioinformatics@flhealth.gov)

### ⚖️ License

Daytona Chikungunya is licensed under the [MIT License](LICENSE).
