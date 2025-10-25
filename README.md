# WES Analysis Pipeline

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.6+](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![Bash](https://img.shields.io/badge/bash-4.0+-green.svg)](https://www.gnu.org/software/bash/)

A comprehensive Whole Exome Sequencing (WES) analysis pipeline with parallel processing, quality control, variant calling, and annotation.

## Features

✨ **Parallel Processing**: Process 2 samples simultaneously for faster analysis  
📊 **Comprehensive QC**: FastQC, MultiQC, and SeqKit statistics  
🧬 **Complete Variant Calling**: GATK best practices workflow  
📝 **ANNOVAR Annotation**: Multi-database variant annotation  
📈 **Summary Reports**: Automated generation of alignment and variant statistics  
🔧 **Modular Design**: Standalone scripts for each analysis step  

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Main Pipeline](#main-pipeline)
  - [Standalone Summary Scripts](#standalone-summary-scripts)
- [Pipeline Steps](#pipeline-steps)
- [Output Structure](#output-structure)
- [Configuration](#configuration)
- [Citation](#citation)
- [License](#license)

## Requirements

### Software Dependencies

| Tool | Version | Purpose |
|------|---------|---------|
| **FastQC** | ≥0.11.9 | Quality control |
| **fastp** | ≥0.20.0 | Read trimming |
| **MultiQC** | ≥1.9 | QC aggregation |
| **SeqKit** | ≥2.0.0 | Sequence statistics |
| **BWA** | ≥0.7.17 | Read alignment |
| **SAMtools** | ≥1.10 | BAM manipulation |
| **GATK** | ≥4.2.0 | Variant calling |
| **BCFtools** | ≥1.10 | VCF manipulation |
| **RTG Tools** | ≥3.12 | VCF statistics |
| **ANNOVAR** | Latest | Variant annotation |
| **Python** | ≥3.6 | Summary scripts |
| **pandas** | ≥1.0.0 | Data processing |

### Optional

- **GNU Parallel**: For efficient parallel processing (recommended)

### Reference Databases

The pipeline requires the following reference files (GATK hg38 bundle):

- `Homo_sapiens_assembly38.fasta`
- `hapmap_3.3.hg38.vcf.gz`
- `1000G_omni2.5.hg38.vcf.gz`
- `1000G_phase1.snps.high_confidence.hg38.vcf.gz`
- `Homo_sapiens_assembly38.dbsnp138.vcf`
- `Homo_sapiens_assembly38.known_indels.vcf.gz`
- `Mills_and_1000G_gold_standard.indels.hg38.vcf.gz`
- Exome capture BED file (e.g., HyperExomeV2_capture_targets.bed)

### ANNOVAR Databases

Download the following ANNOVAR databases:
- ensGene
- dbnsfp42c
- clinvar_20250721
- avsnp151
- gnomad41_exome
- ALL.sites.2015_08
- SAS.sites.2015_08

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/WES-Analysis-Pipeline.git
cd WES-Analysis-Pipeline
```

### 2. Install Dependencies

**Using Conda (recommended):**

```bash
conda env create -f environment.yml
conda activate wes_pipeline
```

**Or install manually:**

```bash
# FastQC
conda install -c bioconda fastqc

# fastp
conda install -c bioconda fastp

# MultiQC
pip install multiqc

# SeqKit
conda install -c bioconda seqkit

# BWA
conda install -c bioconda bwa

# SAMtools
conda install -c bioconda samtools

# GATK
conda install -c bioconda gatk4

# BCFtools
conda install -c bioconda bcftools

# RTG Tools
conda install -c bioconda rtg-tools

# Python packages
pip install pandas
```

### 3. Configure Database Paths

Edit the database paths in `WES_analysis_with_annovar.sh`:

```bash
# Database paths
dbPath=/path/to/your/Exome_Databases/
annovarPath=/path/to/annovar
annovarDB=/path/to/annovar/humandb
```

### 4. Make Scripts Executable

```bash
chmod +x WES_analysis_with_annovar.sh
chmod +x run_all_summaries.sh
chmod +x *.py
```

## Usage

### Main Pipeline

Run the complete WES analysis pipeline:

```bash
bash WES_analysis_with_annovar.sh <fastq_directory> <threads> <output_directory>
```

**Parameters:**
- `fastq_directory`: Directory containing FASTQ files
- `threads`: Number of threads per sample
- `output_directory`: Output directory for results

**Example:**

```bash
bash WES_analysis_with_annovar.sh /data/fastq 16 /data/results
```

**Sample Naming Convention:**

FASTQ files should follow the naming pattern:
```
SampleName_R1_001.fastq.gz
SampleName_R2_001.fastq.gz
```

Example: `T1_S37_L001_R1_001.fastq.gz`, `T1_S37_L001_R2_001.fastq.gz`

### Standalone Summary Scripts

Generate summaries independently after pipeline completion:

#### 1. Alignment Summary

```bash
python3 alignment_summary.py <BAM_directory>

# Example
python3 alignment_summary.py /data/results/BAM_Files
```

#### 2. VCF Summary (Raw)

```bash
python3 vcf_summary.py <RTG_Raw_directory> raw

# Example
python3 vcf_summary.py /data/results/VCF/RTG_Raw raw
```

#### 3. VCF Summary (PASS)

```bash
python3 vcf_summary.py <RTG_Pass_directory> pass

# Example
python3 vcf_summary.py /data/results/VCF/RTG_Pass pass
```

#### 4. ANNOVAR Summary

```bash
python3 annovar_summary.py <ANNOVAR_directory>

# Example
python3 annovar_summary.py /data/results/VCF/ANNOVAR
```

#### 5. Run All Summaries

```bash
bash run_all_summaries.sh <output_directory>

# Example
bash run_all_summaries.sh /data/results
```

## Pipeline Steps

### 1. Quality Control (Raw Data)
- **SeqKit stats**: Generate sequence statistics (R1 only)
- **FastQC**: Quality assessment of raw reads

### 2. Sample Processing (Parallel: 2 samples)

For each sample:

#### a. Read Preprocessing
- **fastp**: Adapter trimming and quality filtering
  - Quality threshold: Q20
  - Length threshold: 40bp
  - Automatic adapter detection

#### b. Quality Control (Trimmed Data)
- **FastQC**: Quality assessment of trimmed reads
- **SeqKit stats**: Statistics for trimmed reads (R1 only)

#### c. Alignment
- **BWA-MEM**: Align reads to reference genome
- **SAMtools**: Sort and index BAM files
- **SAMtools flagstat**: Generate alignment statistics

#### d. BAM Processing
- **GATK CleanSam**: Clean BAM files
- **GATK MarkDuplicates**: Mark duplicate reads

#### e. Base Quality Score Recalibration (BQSR)
- **GATK BaseRecalibrator**: Calculate recalibration table
- **GATK ApplyBQSR**: Apply BQSR to BAM files

#### f. Variant Calling
- **GATK HaplotypeCaller**: Call variants
- **BCFtools stats**: Generate VCF statistics
- **RTG vcfstats**: Detailed variant statistics

#### g. Variant Filtering
- **SNP Filtering**:
  - FS > 60.0
  - QD < 2.0
  - MQ < 40.0
  - QUAL < 30.0
  - MQRankSum < -12.5
  - ReadPosRankSum < -8.0
  - SOR > 3.0

- **Indel Filtering**:
  - FS > 200.0
  - QD < 2.0
  - ReadPosRankSum < -20.0
  - QUAL < 30.0

#### h. Variant Annotation
- **ANNOVAR**: Comprehensive variant annotation
  - ensGene (gene annotation)
  - dbnsfp42c (functional predictions)
  - clinvar (clinical significance)
  - avsnp151 (dbSNP)
  - gnomad41_exome (population frequencies)
  - 1000 Genomes (ALL and SAS populations)

### 3. QC Aggregation
- **MultiQC**: Generate comprehensive QC reports
  - Separate reports for raw and trimmed data

### 4. Summary Generation
- Alignment summary (mapped reads, percentages)
- VCF statistics (SNPs, indels, Het/Hom ratios)
- ANNOVAR variant categories (exonic, intronic, etc.)

## Output Structure

```
output_directory/
├── Quality/
│   ├── Raw/                    # Raw data FastQC reports
│   ├── Cleaned/                # Trimmed data FastQC reports
│   ├── MultiQC_Raw/            # MultiQC report for raw data
│   │   └── raw_data_multiqc_report.html
│   └── MultiQC_Cleaned/        # MultiQC report for trimmed data
│       └── trimmed_data_multiqc_report.html
├── SeqKit_Stats/
│   ├── raw_data_stats.tsv      # SeqKit stats for raw data (R1 only)
│   └── trimmed_data_stats.tsv  # SeqKit stats for trimmed data (R1 only)
├── TrimmedData/                # Trimmed FASTQ files and fastp reports
│   ├── *_trim_1.fastq.gz
│   ├── *_trim_2.fastq.gz
│   ├── *.json
│   └── *.html
├── BAM_Files/
│   ├── *_alignSort.bam         # Aligned and sorted BAM
│   ├── *_alignSortClean.bam    # Cleaned BAM
│   ├── *_mkDup.bam             # Duplicate-marked BAM
│   ├── *_BQSR.bam              # BQSR recalibrated BAM
│   ├── *_alignSortStats.tsv    # Alignment statistics
│   └── primary_mapped_summary.tsv  # Summary table
└── VCF/
    ├── *_raw.vcf               # Raw variants
    ├── *_pass.vcf              # PASS-filtered variants
    ├── RTG_Raw/
    │   ├── *_rtg_stats.txt     # Per-sample RTG stats
    │   └── vcf_raw_summary.tsv # Summary table
    ├── RTG_Pass/
    │   ├── *_pass_rtg_stats.txt
    │   └── vcf_pass_summary.tsv
    └── ANNOVAR/
        ├── *_annovar.vcf.hg38_multianno.txt  # Annotated variants
        └── variant_category_summary.tsv       # Summary table
```

## Configuration

### Parallel Processing

The pipeline processes **2 samples in parallel** by default. To change this:

1. Edit `WES_analysis_with_annovar.sh`
2. Modify the `-j` parameter:

```bash
# For GNU parallel
parallel -j 4 process_sample {}  # Process 4 samples in parallel

# For background jobs
if [ $((count % 4)) -eq 0 ]; then  # Process 4 samples in parallel
    wait
fi
```

### Thread Allocation

With 2 samples running in parallel:
- **Total cores = 32**: Use `threads=16` (16 cores per sample)
- **Total cores = 64**: Use `threads=32` (32 cores per sample)

### Filtering Thresholds

To modify variant filtering criteria, edit the `VariantFiltration` commands in the script.

## Performance

### Estimated Runtime

For a typical WES sample (~12GB per FASTQ pair):

| Step | Time (16 cores) |
|------|----------------|
| QC + Trimming | 30 min |
| Alignment | 2-3 hours |
| Variant Calling | 1-2 hours |
| Annotation | 20-30 min |
| **Total per sample** | **4-6 hours** |

With 2 samples in parallel: **~4-6 hours for 2 samples**

### Resource Requirements

- **CPU**: 32+ cores recommended (16 per sample × 2 parallel)
- **RAM**: 64+ GB recommended (32GB per sample × 2 parallel)
- **Storage**: ~100GB per sample (intermediate + final files)

## Troubleshooting

### Common Issues

1. **"No ANNOVAR .txt files found"**
   - Check ANNOVAR database paths
   - Ensure ANNOVAR completed successfully
   - Verify file naming convention

2. **"command not found" errors**
   - Ensure all dependencies are installed
   - Check PATH environment variable
   - Activate conda environment

3. **Out of memory errors**
   - Reduce parallel samples to 1
   - Increase allocated memory
   - Reduce threads per sample

4. **GATK errors**
   - Check reference genome paths
   - Verify all index files exist (.fai, .dict)
   - Check known sites VCF files

## Citation

If you use this pipeline in your research, please cite:

```
WES Analysis Pipeline
https://github.com/yourusername/WES-Analysis-Pipeline
```

### Tools Citations

- **FastQC**: Andrews S. (2010). FastQC
- **fastp**: Chen et al. (2018). Bioinformatics 34:i884-i890
- **BWA**: Li & Durbin (2009). Bioinformatics 25:1754-1760
- **GATK**: McKenna et al. (2010). Genome Research 20:1297-1303
- **ANNOVAR**: Wang et al. (2010). Nucleic Acids Research 38:e164

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or issues, please:
- Open an issue on GitHub
- Contact: your.email@example.com

## Acknowledgments

- GATK Best Practices Workflow
- Broad Institute Resource Bundle
- ANNOVAR database maintainers

---

**Last Updated**: January 2025  
**Version**: 1.0.0

