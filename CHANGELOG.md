# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-25

### Added
- Initial release of WES Analysis Pipeline
- Complete GATK best practices workflow implementation
- Parallel processing support (2 samples simultaneously)
- Comprehensive quality control with FastQC, fastp, and MultiQC
- SeqKit statistics generation for raw and trimmed data (R1 only)
- ANNOVAR multi-database variant annotation
- RTG Tools integration for detailed VCF statistics
- Automated summary generation for:
  - Alignment statistics
  - Raw VCF statistics
  - PASS-filtered VCF statistics
  - ANNOVAR variant categories
- Standalone Python scripts for independent summary generation
- Master script to run all summaries at once
- Comprehensive documentation and README
- MIT License

### Features
- **Quality Control**
  - FastQC for raw and trimmed reads
  - SeqKit stats (R1 only) for sequence statistics
  - MultiQC reports with separate outputs for raw and trimmed data
  
- **Read Processing**
  - fastp for adapter trimming and quality filtering
  - Configurable quality and length thresholds
  
- **Alignment**
  - BWA-MEM alignment
  - SAMtools for BAM processing
  - GATK CleanSam and MarkDuplicates
  
- **Base Quality Score Recalibration (BQSR)**
  - GATK BaseRecalibrator
  - Multiple known sites databases
  
- **Variant Calling**
  - GATK HaplotypeCaller
  - Separate SNP and Indel filtering
  - Strict quality filters
  
- **Variant Annotation**
  - ANNOVAR with 7 databases:
    - ensGene (gene annotation)
    - dbnsfp42c (functional predictions)
    - clinvar (clinical significance)
    - avsnp151 (dbSNP)
    - gnomad41_exome (population frequencies)
    - 1000 Genomes (ALL and SAS populations)
  
- **Statistics and Reports**
  - RTG vcfstats for raw and PASS VCFs
  - Alignment summary tables
  - VCF statistics summaries
  - ANNOVAR variant category summaries

### Technical Details
- Parallel processing: 2 samples simultaneously (configurable)
- Support for GNU parallel and background jobs
- Modular design with standalone summary scripts
- Comprehensive error handling
- Progress tracking and logging

### Documentation
- Comprehensive README with installation instructions
- Usage examples for all scripts
- Output structure documentation
- Troubleshooting guide
- Performance benchmarks
- Citation information

## [Unreleased]

### Planned Features
- Support for single-end sequencing
- Joint genotyping mode for multiple samples
- CNV calling integration
- Structural variant detection
- Custom filtering profiles
- Docker container support
- Configuration file support (YAML)
- Resume functionality for interrupted runs
- Email notifications upon completion

---

## Version History

- **1.0.0** (2025-01-25): Initial release

