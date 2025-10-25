# Quick Start Guide

Get started with the WES Analysis Pipeline in 5 minutes!

## Prerequisites

- Linux operating system
- 32+ GB RAM
- 16+ CPU cores
- 500+ GB storage

## Step 1: Install Dependencies

### Option A: Using Conda (Recommended)

```bash
# Install Miniconda if not already installed
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# Create and activate environment
conda env create -f environment.yml
conda activate wes_pipeline
```

### Option B: Manual Installation

```bash
# Install via conda
conda install -c bioconda fastqc fastp multiqc seqkit bwa samtools gatk4 bcftools rtg-tools

# Install Python packages
pip install pandas
```

## Step 2: Download Reference Files

### GATK Resource Bundle (hg38)

```bash
# Create reference directory
mkdir -p ~/references/hg38
cd ~/references/hg38

# Download GATK bundle (use appropriate method for your setup)
# Option 1: Using Google Cloud
gsutil -m cp -r gs://genomics-public-data/resources/broad/hg38/v0/* .

# Option 2: From Broad Institute FTP
# Visit: https://console.cloud.google.com/storage/browser/genomics-public-data/resources/broad/hg38/v0
```

### Required Files:
- Homo_sapiens_assembly38.fasta (+ .fai, .dict)
- hapmap_3.3.hg38.vcf.gz (+ .tbi)
- 1000G_omni2.5.hg38.vcf.gz (+ .tbi)
- 1000G_phase1.snps.high_confidence.hg38.vcf.gz (+ .tbi)
- Homo_sapiens_assembly38.dbsnp138.vcf (+ .idx)
- Homo_sapiens_assembly38.known_indels.vcf.gz (+ .tbi)
- Mills_and_1000G_gold_standard.indels.hg38.vcf.gz (+ .tbi)

## Step 3: Install and Configure ANNOVAR

```bash
# Download ANNOVAR
# Request from: http://www.openbioinformatics.org/annovar/annovar_download_form.php

# Extract
tar -xvzf annovar.latest.tar.gz
cd annovar

# Download databases
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar ensGene humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar dbnsfp42c humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar clinvar_20250721 humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar avsnp151 humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar gnomad41_exome humandb/
./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar 1000g2015aug humandb/
```

## Step 4: Configure Pipeline

Edit `WES_analysis_with_annovar.sh` to update paths:

```bash
# Database paths
dbPath=/home/yourusername/references/hg38/
annovarPath=/home/yourusername/annovar
annovarDB=/home/yourusername/annovar/humandb
bedFile=$dbPath/your_capture_targets.bed  # Update to your capture kit
```

## Step 5: Prepare Your Data

Organize FASTQ files:

```
/data/fastq/
├── Sample1_S1_L001_R1_001.fastq.gz
├── Sample1_S1_L001_R2_001.fastq.gz
├── Sample2_S2_L001_R1_001.fastq.gz
└── Sample2_S2_L001_R2_001.fastq.gz
```

## Step 6: Run the Pipeline

```bash
# Basic usage (16 threads per sample, 2 samples in parallel = 32 cores total)
bash WES_analysis_with_annovar.sh /data/fastq 16 /data/results

# Monitor progress
tail -f nohup.out  # If running with nohup
```

## Step 7: Check Results

```bash
# Check output structure
tree -L 2 /data/results

# View summary reports
cat /data/results/BAM_Files/primary_mapped_summary.tsv
cat /data/results/VCF/RTG_Pass/vcf_pass_summary.tsv
cat /data/results/VCF/ANNOVAR/variant_category_summary.tsv

# Open MultiQC reports in browser
firefox /data/results/Quality/MultiQC_Raw/raw_data_multiqc_report.html
firefox /data/results/Quality/MultiQC_Cleaned/trimmed_data_multiqc_report.html
```

## Quick Examples

### Example 1: Test Run with 2 Samples

```bash
# Create test directory
mkdir -p ~/wes_test

# Copy 2 sample pairs to test directory
cp /path/to/sample1_R*.fastq.gz ~/wes_test/
cp /path/to/sample2_R*.fastq.gz ~/wes_test/

# Run pipeline
bash WES_analysis_with_annovar.sh ~/wes_test 8 ~/wes_results

# Estimated time: 6-8 hours for 2 samples
```

### Example 2: Running with Nohup

```bash
# Run in background (survives terminal disconnect)
nohup bash WES_analysis_with_annovar.sh /data/fastq 16 /data/results > pipeline.log 2>&1 &

# Check progress
tail -f pipeline.log
```

### Example 3: Running on HPC with SLURM

Create `wes_pipeline.sbatch`:

```bash
#!/bin/bash
#SBATCH --job-name=wes_pipeline
#SBATCH --output=wes_%j.log
#SBATCH --error=wes_%j.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=32
#SBATCH --mem=64G

# Load required modules (adjust for your HPC)
module load conda
source activate wes_pipeline

# Run pipeline
bash WES_analysis_with_annovar.sh /data/fastq 16 /scratch/results
```

Submit job:
```bash
sbatch wes_pipeline.sbatch
```

### Example 4: Generate Summaries Only

If you've already run the pipeline and only need to regenerate summaries:

```bash
# Run all summaries
bash run_all_summaries.sh /data/results

# Or run individual summaries
python3 alignment_summary.py /data/results/BAM_Files
python3 vcf_summary.py /data/results/VCF/RTG_Pass pass
python3 annovar_summary.py /data/results/VCF/ANNOVAR
```

## Troubleshooting Quick Fixes

### Issue: "command not found"
```bash
# Make sure conda environment is activated
conda activate wes_pipeline

# Or check PATH
which fastqc
which bwa
which gatk
```

### Issue: Out of memory
```bash
# Reduce parallel samples to 1
# Edit WES_analysis_with_annovar.sh line 298:
parallel -j 1 process_sample {}  # Change from -j 2 to -j 1
```

### Issue: ANNOVAR not found
```bash
# Check ANNOVAR path in script
grep annovarPath WES_analysis_with_annovar.sh

# Make sure table_annovar.pl is executable
chmod +x /path/to/annovar/table_annovar.pl
```

### Issue: Reference files not found
```bash
# Verify all required files exist
ls -lh ~/references/hg38/*.fasta
ls -lh ~/references/hg38/*.vcf.gz
ls -lh ~/references/hg38/*.vcf

# Check for index files (.fai, .dict, .tbi, .idx)
```

## Performance Tips

1. **Use GNU Parallel** (if available): Much faster than background jobs
   ```bash
   conda install -c conda-forge parallel
   ```

2. **Adjust Thread Allocation**: 
   - Total cores = 32: use `threads=16` (2 samples × 16 cores)
   - Total cores = 64: use `threads=32` (2 samples × 32 cores)

3. **Use Fast Storage**: Run on SSD/NVMe for better I/O performance

4. **Pre-index References**: Ensure all reference files are pre-indexed

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [CHANGELOG.md](CHANGELOG.md) for version history
- Explore output files and customize filtering parameters
- Integrate with your downstream analysis workflow

## Getting Help

- GitHub Issues: https://github.com/yourusername/WES-Analysis-Pipeline/issues
- Email: snehagoel3142@gmail.com
---

Happy analyzing! 🧬

