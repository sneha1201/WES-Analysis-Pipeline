#!/bin/bash
set -e
set -o pipefail

# ============================================================================
# WES Analysis Pipeline - Updated Version
# Includes: SeqKit stats, FastQC, MultiQC, RTG stats, ANNOVAR, and summary reports
# Parallel processing: 2 samples at a time
# ============================================================================

# Database paths
dbPath=/Analysis/sneha/Exome_Databases/
annovarPath=/data/annovar
annovarDB=/data/annovar/humandb
Ref_hg38=$dbPath/resources_broad_hg38_v0_Homo_sapiens_assembly38.fasta
hapmap_vcf=$dbPath/resources_broad_hg38_v0_hapmap_3.3.hg38.vcf.gz
omni_vcf=$dbPath/resources_broad_hg38_v0_1000G_omni2.5.hg38.vcf.gz
G1000_vcf=$dbPath/resources_broad_hg38_v0_1000G_phase1.snps.high_confidence.hg38.vcf.gz
dbsnp_vcf=$dbPath/resources_broad_hg38_v0_Homo_sapiens_assembly38.dbsnp138.vcf
dbIndel_vcf=$dbPath/resources_broad_hg38_v0_Homo_sapiens_assembly38.known_indels.vcf.gz
Mills_vcf=$dbPath/resources_broad_hg38_v0_Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
bedFile=$dbPath/HyperExomeV2_capture_targets.bed

# Arguments
batch=$1
threads=$2
output=$3

samplepath=${batch}

# ============================================================================
# Create output directories
# ============================================================================
mkdir -p ${output}/Quality/Raw
mkdir -p ${output}/Quality/Cleaned
mkdir -p ${output}/Quality/MultiQC_Raw
mkdir -p ${output}/Quality/MultiQC_Cleaned
mkdir -p ${output}/TrimmedData
mkdir -p ${output}/SeqKit_Stats
mkdir -p ${output}/BAM_Files
mkdir -p ${output}/VCF
mkdir -p ${output}/VCF/RTG_Raw
mkdir -p ${output}/VCF/RTG_Pass
mkdir -p ${output}/VCF/ANNOVAR

qualityPath_raw=${output}/Quality/Raw
qualityPath_cleaned=${output}/Quality/Cleaned
trimmedDataPath=${output}/TrimmedData
seqkitPath=${output}/SeqKit_Stats
bamPath=${output}/BAM_Files
vcfPath=${output}/VCF

echo "=== WES Analysis Pipeline Started ==="
echo "Batch: $batch"
echo "Threads: $threads"
echo "Output: $output"
echo "Parallel samples: 2"
echo ""

# ============================================================================
# Step 1: SeqKit stats for raw data (R1 only)
# ============================================================================
echo "========================================="
echo "Step 1: Running SeqKit stats on raw data (R1 only)"
echo "========================================="

seqkit stats -a -j $threads $samplepath/*_R1_001.fastq.gz \
  > $seqkitPath/raw_data_stats.tsv

echo "✓ SeqKit stats for raw data completed"
echo ""

# ============================================================================
# Step 2: Process each sample (2 samples in parallel)
# ============================================================================

# Function to process a single sample
process_sample() {
    local file=$1
    local base=$(basename $file _R1_001.fastq.gz)
    
    echo "========================================="
    echo "Processing Sample: ${base}"
    echo "========================================="
    
    # --- Quality Checking of Raw Data ---
    echo "[${base}] FastQC on raw data..."
    fastqc -t $threads -o $qualityPath_raw \
        $samplepath/${base}_R1_001.fastq.gz \
        $samplepath/${base}_R2_001.fastq.gz
    
    # --- Trimming with fastp ---
    echo "[${base}] Trimming with fastp..."
    fastp --in1 $samplepath/${base}_R1_001.fastq.gz \
          --in2 $samplepath/${base}_R2_001.fastq.gz \
          -q 20 -u 20 -l 40 --detect_adapter_for_pe \
          --out1 $trimmedDataPath/${base}_trim_1.fastq.gz \
          --out2 $trimmedDataPath/${base}_trim_2.fastq.gz \
          -w $threads \
          --json $trimmedDataPath/${base}.json \
          --html $trimmedDataPath/${base}.html
    
    # --- Quality Checking of Trimmed Data ---
    echo "[${base}] FastQC on trimmed data..."
    fastqc -t $threads -o $qualityPath_cleaned \
        $trimmedDataPath/${base}_trim_1.fastq.gz \
        $trimmedDataPath/${base}_trim_2.fastq.gz
    
    # --- Alignment and BAM generation ---
    echo "[${base}] Aligning reads with BWA-MEM..."
    
    fastq1=$trimmedDataPath/${base}_trim_1.fastq.gz
    fastq2=$trimmedDataPath/${base}_trim_2.fastq.gz
    alignBam=$bamPath/${base}_alignSort.bam
    cleanBam=$bamPath/${base}_alignSortClean.bam
    mkDupBam=$bamPath/${base}_mkDup.bam
    recalTable=$bamPath/${base}_recal.table
    bqsrBam=$bamPath/${base}_BQSR.bam
    
    bwa mem -M -t $threads $Ref_hg38 $fastq1 $fastq2 \
        -R "@RG\\tID:${base}\\tSM:${base}\\tPL:ILLUMINA\\tPU:Lane4\\tLB:ILLUMINA" | \
        samtools view -S -b | \
        samtools sort -@ $threads -o $alignBam
    
    samtools index -@ $threads $alignBam
    samtools flagstat $alignBam -O tsv > $bamPath/${base}_alignSortStats.tsv
    
    echo "[${base}] Cleaning and marking duplicates..."
    gatk CleanSam --CREATE_INDEX true -I $alignBam -O $cleanBam
    gatk MarkDuplicates -I $cleanBam -O $mkDupBam -M $bamPath/${base}_metrics.txt
    
    # --- Base Quality Score Recalibration ---
    echo "[${base}] Base recalibration..."
    gatk BaseRecalibrator \
        -R $Ref_hg38 \
        -I $mkDupBam \
        --known-sites $hapmap_vcf \
        --known-sites $G1000_vcf \
        --known-sites $dbIndel_vcf \
        --known-sites $dbsnp_vcf \
        --known-sites $omni_vcf \
        --known-sites $Mills_vcf \
        -O $recalTable
    
    gatk ApplyBQSR \
        -R $Ref_hg38 \
        -I $mkDupBam \
        -O $bqsrBam \
        --static-quantized-quals 10 \
        --static-quantized-quals 20 \
        --static-quantized-quals 30 \
        --bqsr $recalTable
    
    # --- Variant Calling ---
    echo "[${base}] Variant calling with HaplotypeCaller..."
    
    rawVcf=$vcfPath/${base}_raw.vcf
    rawSnpVcf=$vcfPath/${base}_rawSNP.vcf
    rawFilterSnpVcf=$vcfPath/${base}_rawFilterSNP.vcf
    rawIndelVcf=$vcfPath/${base}_rawIndel.vcf
    rawFilterIndelVcf=$vcfPath/${base}_rawFilterIndel.vcf
    mergedVcf=$vcfPath/${base}_merged.vcf
    passedVcf=$vcfPath/${base}_pass.vcf
    
    gatk HaplotypeCaller \
        -R $Ref_hg38 \
        -I $bqsrBam \
        -O $rawVcf \
        -L $bedFile \
        --native-pair-hmm-threads $threads \
        -pairHMM AVX_LOGLESS_CACHING
    
    # --- VCF stats for raw VCF ---
    echo "[${base}] Generating stats for raw VCF..."
    bcftools stats $rawVcf > $vcfPath/${base}_rawStats.txt
    
    # RTG stats for raw VCF
    rtg vcfstats $rawVcf > $vcfPath/RTG_Raw/${base}_rtg_stats.txt
    
    # --- SNP filtering ---
    echo "[${base}] Filtering SNPs..."
    gatk --java-options '-DGATK_STACKTRACE_ON_USER_EXCEPTION=TRUE' SelectVariants \
        -R $Ref_hg38 \
        -V $rawVcf \
        --select-type-to-include SNP \
        -O $rawSnpVcf
    
    gatk --java-options '-DGATK_STACKTRACE_ON_USER_EXCEPTION=TRUE' VariantFiltration \
        -R $Ref_hg38 \
        -V $rawSnpVcf \
        -filter-name "my_filter_FS" -filter " FS > 60.0 " \
        -filter-name "my_filter_QD" -filter " QD < 2.0 " \
        -filter-name "my_filter_MQ" -filter " MQ < 40.0 " \
        -filter-name "my_filter_QUAL" -filter " QUAL < 30.0 " \
        -filter-name "my_filter_MQRankSum" -filter " MQRankSum < -12.5 " \
        -filter-name "my_filter_ReadPosRankSum" -filter " ReadPosRankSum < -8.0 " \
        -filter-name "my_filter_SOR" -filter " SOR > 3.0 " \
        -O $rawFilterSnpVcf
    
    # --- Indel filtering ---
    echo "[${base}] Filtering Indels..."
    gatk --java-options '-DGATK_STACKTRACE_ON_USER_EXCEPTION=TRUE' SelectVariants \
        -R $Ref_hg38 \
        -V $rawVcf \
        --select-type-to-include INDEL \
        -O $rawIndelVcf
    
    gatk --java-options '-DGATK_STACKTRACE_ON_USER_EXCEPTION=TRUE' VariantFiltration \
        -R $Ref_hg38 \
        -V $rawIndelVcf \
        -filter-name "my_filter_FS" -filter " FS > 200.0 " \
        -filter-name "my_filter_QD" -filter " QD < 2.0" \
        -filter-name "my_filter_ReadPosRankSum" -filter " ReadPosRankSum < -20.0 " \
        -filter-name "my_filter_QUAL" -filter " QUAL < 30.0 " \
        -O $rawFilterIndelVcf
    
    # --- Merge and extract PASS variants ---
    echo "[${base}] Merging VCFs and extracting PASS variants..."
    gatk MergeVcfs -I $rawFilterSnpVcf -I $rawFilterIndelVcf -O $mergedVcf
    bcftools view -f PASS $mergedVcf > $passedVcf
    
    # --- VCF stats for PASS VCF ---
    echo "[${base}] Generating stats for PASS VCF..."
    bcftools stats $passedVcf > $vcfPath/${base}_passStats.txt
    
    # RTG stats for PASS VCF
    rtg vcfstats $passedVcf > $vcfPath/RTG_Pass/${base}_pass_rtg_stats.txt
    
    # --- ANNOVAR Annotation ---
    echo "[${base}] Running ANNOVAR annotation..."
    
    annovarOut=$vcfPath/ANNOVAR/${base}_annovar.vcf
    
    $annovarPath/table_annovar.pl $passedVcf $annovarDB/ \
        --buildver hg38 \
        -outfile $annovarOut \
        --remove \
        --protocol ensGene,dbnsfp42c,clinvar_20250721,avsnp151,gnomad41_exome,ALL.sites.2015_08,SAS.sites.2015_08 \
        --operation g,f,f,f,f,f,f \
        --nastring . \
        --polish \
        -otherinfo \
        --vcfinput
    
    echo "✓ ANNOVAR annotation completed for ${base}"
    echo "✓ Sample ${base} completed"
    echo ""
}

# Export the function and variables for parallel processing
export -f process_sample
export samplepath qualityPath_raw qualityPath_cleaned trimmedDataPath bamPath vcfPath
export threads dbPath annovarPath annovarDB Ref_hg38 hapmap_vcf omni_vcf G1000_vcf
export dbsnp_vcf dbIndel_vcf Mills_vcf bedFile

# Run samples in parallel (2 at a time)
echo "========================================="
echo "Processing samples (2 in parallel)"
echo "========================================="

# Use GNU parallel if available, otherwise use background jobs
if command -v parallel &> /dev/null; then
    echo "Using GNU parallel for processing"
    ls $samplepath/*_R1_001.fastq.gz | parallel -j 2 process_sample {}
else
    echo "Using background jobs for parallel processing"
    # Count for parallel control
    count=0
    for file in $samplepath/*_R1_001.fastq.gz
    do
        process_sample "$file" &
        ((count++))
        
        # Wait when 2 samples are running
        if [ $((count % 2)) -eq 0 ]; then
            wait
        fi
    done
    # Wait for any remaining jobs
    wait
fi

echo "✓ All samples processed"
echo ""

# ============================================================================
# Step 3: SeqKit stats for trimmed data (R1 only)
# ============================================================================
echo "========================================="
echo "Step 3: Running SeqKit stats on trimmed data (R1 only)"
echo "========================================="

seqkit stats -a -j $threads $trimmedDataPath/*_trim_1.fastq.gz \
  > $seqkitPath/trimmed_data_stats.tsv

echo "✓ SeqKit stats for trimmed data completed"
echo ""

# ============================================================================
# Step 4: MultiQC for Raw data
# ============================================================================
echo "========================================="
echo "Step 4: Running MultiQC on raw data QC"
echo "========================================="

multiqc $qualityPath_raw \
    -o ${output}/Quality/MultiQC_Raw \
    -n raw_data_multiqc_report \
    --title "Raw Data Quality Report - Batch ${batch}" \
    --force

echo "✓ MultiQC for raw data completed"
echo ""

# ============================================================================
# Step 5: MultiQC for Cleaned/Trimmed data
# ============================================================================
echo "========================================="
echo "Step 5: Running MultiQC on trimmed data QC"
echo "========================================="

multiqc $qualityPath_cleaned $trimmedDataPath \
    -o ${output}/Quality/MultiQC_Cleaned \
    -n trimmed_data_multiqc_report \
    --title "Trimmed Data Quality Report - Batch ${batch}" \
    --force

echo "✓ MultiQC for trimmed data completed"
echo ""

# ============================================================================
# Step 6: Generate alignment summary
# ============================================================================
echo "========================================="
echo "Step 6: Generating alignment summary"
echo "========================================="

python3 << PYTHON_SCRIPT_1
import os
import glob
import pandas as pd
import sys

stats_dir = "${bamPath}"

# Find stats files
stats_files = glob.glob(os.path.join(stats_dir, "*_alignSortStats.tsv"))

if not stats_files:
    print(f"No *_alignSortStats.tsv files found in '{stats_dir}'")
    sys.exit(0)

# Parse files
rows = []
for filepath in stats_files:
    sample = os.path.basename(filepath).split('_alignSortStats.tsv')[0]
    total_reads = None
    primary_mapped_reads = None
    primary_aligned_percentage = None
    
    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if line.endswith("total (QC-passed reads + QC-failed reads)"):
                total_reads = line.split()[0]
            elif 'primary mapped' in line and not line.endswith("primary mapped %"):
                primary_mapped_reads = line.split()[0]
            elif line.endswith("primary mapped %"):
                primary_aligned_percentage = line.split()[0]
    
    rows.append({
        "Sample": sample,
        "Total reads": total_reads,
        "Primary mapped reads": primary_mapped_reads,
        "Primary aligned percentage": primary_aligned_percentage
    })

# Save results
df = pd.DataFrame(rows)
df = df.sort_values(by="Sample").reset_index(drop=True)
out_file = os.path.join(stats_dir, "primary_mapped_summary.tsv")
df.to_csv(out_file, sep="\t", index=False)

print(f"\n✅ Alignment summary saved to: {out_file}\n")
print(df.to_string(index=False))
PYTHON_SCRIPT_1

echo ""

# ============================================================================
# Step 7: Generate VCF stats summary (Raw VCF)
# ============================================================================
echo "========================================="
echo "Step 7: Generating VCF summary (Raw)"
echo "========================================="

python3 << PYTHON_SCRIPT_2
import os
import glob
import pandas as pd

stats_dir = "${vcfPath}/RTG_Raw"
stats_files = glob.glob(os.path.join(stats_dir, "*_rtg_stats.txt"))

if not stats_files:
    print(f"No RTG stats files found in {stats_dir}")
else:
    rows = []
    for filepath in stats_files:
        sample = os.path.basename(filepath).replace("_rtg_stats.txt", "")
        passed = snps = ins = dels = indels = het_hom = None
        
        with open(filepath) as f:
            for line in f:
                if line.startswith("Passed Filters"):
                    passed = line.split(":")[1].strip()
                elif line.startswith("SNPs "):
                    snps = line.split(":")[1].strip()
                elif line.startswith("Insertions"):
                    ins = line.split(":")[1].strip()
                elif line.startswith("Deletions"):
                    dels = line.split(":")[1].strip()
                elif line.startswith("Indels "):
                    indels = line.split(":")[1].strip()
                elif line.startswith("Total Het/Hom ratio"):
                    het_hom = line.split(":")[1].strip().split()[0]
        
        rows.append({
            "Sample": sample,
            "Passed Filters": passed,
            "no of SNPs": snps,
            "no of Insertions": ins,
            "no of Deletions": dels,
            "no of Indels": indels,
            "Het/Hom ratio": het_hom
        })
    
    df = pd.DataFrame(rows)
    df = df.sort_values(by="Sample").reset_index(drop=True)
    out_file = os.path.join(stats_dir, "vcf_raw_summary.tsv")
    df.to_csv(out_file, sep="\t", index=False)
    
    print(f"✅ Raw VCF summary saved to: {out_file}")
    print(df.to_string(index=False))
PYTHON_SCRIPT_2

echo ""

# ============================================================================
# Step 8: Generate VCF stats summary (PASS VCF)
# ============================================================================
echo "========================================="
echo "Step 8: Generating VCF summary (PASS)"
echo "========================================="

python3 << PYTHON_SCRIPT_3
import os
import glob
import pandas as pd

stats_dir = "${vcfPath}/RTG_Pass"
stats_files = glob.glob(os.path.join(stats_dir, "*_pass_rtg_stats.txt"))

if not stats_files:
    print(f"No RTG stats files found in {stats_dir}")
else:
    rows = []
    for filepath in stats_files:
        sample = os.path.basename(filepath).replace("_pass_rtg_stats.txt", "")
        passed = snps = ins = dels = indels = het_hom = None
        
        with open(filepath) as f:
            for line in f:
                if line.startswith("Passed Filters"):
                    passed = line.split(":")[1].strip()
                elif line.startswith("SNPs "):
                    snps = line.split(":")[1].strip()
                elif line.startswith("Insertions"):
                    ins = line.split(":")[1].strip()
                elif line.startswith("Deletions"):
                    dels = line.split(":")[1].strip()
                elif line.startswith("Indels "):
                    indels = line.split(":")[1].strip()
                elif line.startswith("Total Het/Hom ratio"):
                    het_hom = line.split(":")[1].strip().split()[0]
        
        rows.append({
            "Sample": sample,
            "Passed Filters": passed,
            "no of SNPs": snps,
            "no of Insertions": ins,
            "no of Deletions": dels,
            "no of Indels": indels,
            "Het/Hom ratio": het_hom
        })
    
    df = pd.DataFrame(rows)
    df = df.sort_values(by="Sample").reset_index(drop=True)
    out_file = os.path.join(stats_dir, "vcf_pass_summary.tsv")
    df.to_csv(out_file, sep="\t", index=False)
    
    print(f"✅ PASS VCF summary saved to: {out_file}")
    print(df.to_string(index=False))
PYTHON_SCRIPT_3

echo ""

# ============================================================================
# Step 9: Generate ANNOVAR variant category summary
# ============================================================================
echo "========================================="
echo "Step 9: Generating ANNOVAR summary"
echo "========================================="

python3 << PYTHON_SCRIPT_4
import pandas as pd
import glob
import os

# Folder containing all the ANNOVAR output files (.txt files with tab-separated values)
annovar_dir = "${vcfPath}/ANNOVAR"
tsv_files = glob.glob(os.path.join(annovar_dir, "*.hg38_multianno.txt"))

if not tsv_files:
    print(f"No ANNOVAR .txt files found in {annovar_dir}")
else:
    results = []
    
    for file in tsv_files:
        # Extract sample name (before '_annovar.vcf...'):
        sample = os.path.basename(file).split('_annovar.vcf')[0]
        
        try:
            # Read TSV
            df = pd.read_csv(file, sep="\t", dtype=str, low_memory=False)
            
            # Count total variants
            total = len(df)
            
            # Count categories in Func.ensGene column if it exists
            if "Func.ensGene" in df.columns:
                counts = {
                    "Sample": sample,
                    "Total_Variants": total,
                    "exonic": (df["Func.ensGene"] == "exonic").sum(),
                    "intronic": (df["Func.ensGene"] == "intronic").sum(),
                    "upstream": (df["Func.ensGene"] == "upstream").sum(),
                    "downstream": (df["Func.ensGene"] == "downstream").sum(),
                    "UTR3": (df["Func.ensGene"] == "UTR3").sum(),
                    "UTR5": (df["Func.ensGene"] == "UTR5").sum(),
                    "splicing": (df["Func.ensGene"] == "splicing").sum(),
                    "ncRNA_exonic": (df["Func.ensGene"] == "ncRNA_exonic").sum(),
                    "ncRNA_intronic": (df["Func.ensGene"] == "ncRNA_intronic").sum(),
                    "intergenic": (df["Func.ensGene"] == "intergenic").sum()
                }
            else:
                counts = {
                    "Sample": sample,
                    "Total_Variants": total,
                    "Note": "Func.ensGene column not found"
                }
            
            results.append(counts)
            
        except Exception as e:
            print(f"Error processing {file}: {e}")
            results.append({
                "Sample": sample,
                "Error": str(e)
            })
    
    # Combine all results into one table
    summary_df = pd.DataFrame(results)
    summary_df = summary_df.sort_values(by="Sample").reset_index(drop=True)
    
    # Save to TSV
    out_file = os.path.join(annovar_dir, "variant_category_summary.tsv")
    summary_df.to_csv(out_file, sep="\t", index=False)
    
    print(f"✅ ANNOVAR summary saved to: {out_file}")
    print()
    print(summary_df.to_string(index=False))
PYTHON_SCRIPT_4

echo ""

# ============================================================================
# Pipeline Completion
# ============================================================================
echo "========================================="
echo "✅ WES Analysis Pipeline Completed!"
echo "========================================="
echo ""
echo "Output directory structure:"
echo "${output}/"
echo "├── Quality/"
echo "│   ├── Raw/                    # Raw data FastQC"
echo "│   ├── Cleaned/                # Trimmed data FastQC"
echo "│   ├── MultiQC_Raw/            # MultiQC report for raw data"
echo "│   └── MultiQC_Cleaned/        # MultiQC report for trimmed data"
echo "├── SeqKit_Stats/"
echo "│   ├── raw_data_stats.tsv      # SeqKit stats for raw data (R1 only)"
echo "│   └── trimmed_data_stats.tsv  # SeqKit stats for trimmed data (R1 only)"
echo "├── TrimmedData/                # Trimmed FASTQ files and fastp reports"
echo "├── BAM_Files/"
echo "│   ├── primary_mapped_summary.tsv  # Alignment summary"
echo "│   └── *_BQSR.bam              # BQSR recalibrated BAM files"
echo "└── VCF/"
echo "    ├── RTG_Raw/                # RTG stats for raw VCFs"
echo "    │   └── vcf_raw_summary.tsv"
echo "    ├── RTG_Pass/               # RTG stats for PASS VCFs"
echo "    │   └── vcf_pass_summary.tsv"
echo "    └── ANNOVAR/"
echo "        ├── variant_category_summary.tsv  # ANNOVAR summary"
echo "        └── *_annovar.vcf.hg38_multianno.txt  # Annotated variants"
echo ""
echo "Analysis completed at: $(date)"

