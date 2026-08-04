#!/usr/bin/env bash
#SBATCH --account=bphl-umbrella
#SBATCH --qos=bphl-umbrella
#SBATCH --job-name=daytona_chikv
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100gb
#SBATCH --time=04:00:00
#SBATCH --output=daytona_chikv.%j.out
#SBATCH --error=daytona_chikv.%j.err
#SBATCH --mail-user=your@email.gov
#SBATCH --mail-type=FAIL,END

module load conda apptainer nextflow
conda activate daytona_chikv

# Path to container image cache directory
export NXF_APPTAINER_CACHEDIR=/path/to/apptainer/cache

# Plain text Nextflow log
export NXF_ANSI_LOG=false

# Run pipeline
nextflow run daytona_chikv.nf -profile apptainer -params-file params.yaml

# Rename output directory with timestamp on success
nxf_exit=$?
output_dir=$(grep '^output:' params.yaml | sed 's/output:[[:space:]]*//' | tr -d '"')
if [ $nxf_exit -eq 0 ] && [ -d "$output_dir" ]; then
    dt=$(date "+%Y%m%d%H%M%S")
    mv "$output_dir" "${output_dir}-${dt}"
elif [ $nxf_exit -ne 0 ]; then
    echo "Pipeline did not complete successfully." >&2
else
    echo "Pipeline exited 0 but output directory not found: $output_dir" >&2
fi
