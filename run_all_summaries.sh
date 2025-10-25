#!/bin/bash

# ============================================================================
# Run All Summary Scripts
# ============================================================================
# This script runs all WES analysis summary scripts in one go.
#
# Usage: bash run_all_summaries.sh <output_directory>
#
# Example: bash run_all_summaries.sh Analysis
# ============================================================================

set -e

# Check if output directory is provided
if [ $# -ne 1 ]; then
    echo "Usage: bash run_all_summaries.sh <output_directory>"
    echo ""
    echo "Example:"
    echo "  bash run_all_summaries.sh Analysis"
    exit 1
fi

output=$1

# Get the directory where the scripts are located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "============================================================"
echo "WES Analysis - Summary Generation"
echo "============================================================"
echo "Output directory: $output"
echo "Script directory: $SCRIPT_DIR"
echo ""

# Check if output directory exists
if [ ! -d "$output" ]; then
    echo "❌ Error: Output directory '$output' does not exist!"
    exit 1
fi

# ============================================================================
# Step 1: Alignment Summary
# ============================================================================
echo "========================================="
echo "Step 1: Generating Alignment Summary"
echo "========================================="

if [ -d "${output}/BAM_Files" ]; then
    python3 "${SCRIPT_DIR}/alignment_summary.py" "${output}/BAM_Files"
    echo ""
else
    echo "⚠ Warning: BAM_Files directory not found, skipping..."
    echo ""
fi

# ============================================================================
# Step 2: VCF Summary (Raw)
# ============================================================================
echo "========================================="
echo "Step 2: Generating VCF Summary (Raw)"
echo "========================================="

if [ -d "${output}/VCF/RTG_Raw" ]; then
    python3 "${SCRIPT_DIR}/vcf_summary.py" "${output}/VCF/RTG_Raw" raw
    echo ""
else
    echo "⚠ Warning: VCF/RTG_Raw directory not found, skipping..."
    echo ""
fi

# ============================================================================
# Step 3: VCF Summary (PASS)
# ============================================================================
echo "========================================="
echo "Step 3: Generating VCF Summary (PASS)"
echo "========================================="

if [ -d "${output}/VCF/RTG_Pass" ]; then
    python3 "${SCRIPT_DIR}/vcf_summary.py" "${output}/VCF/RTG_Pass" pass
    echo ""
else
    echo "⚠ Warning: VCF/RTG_Pass directory not found, skipping..."
    echo ""
fi

# ============================================================================
# Step 4: ANNOVAR Variant Category Summary
# ============================================================================
echo "========================================="
echo "Step 4: Generating ANNOVAR Summary"
echo "========================================="

if [ -d "${output}/VCF/ANNOVAR" ]; then
    python3 "${SCRIPT_DIR}/annovar_summary.py" "${output}/VCF/ANNOVAR"
    echo ""
else
    echo "⚠ Warning: VCF/ANNOVAR directory not found, skipping..."
    echo ""
fi

# ============================================================================
# Completion
# ============================================================================
echo "============================================================"
echo "✅ All Summaries Generated!"
echo "============================================================"
echo ""
echo "Summary files created:"
echo "  ${output}/BAM_Files/primary_mapped_summary.tsv"
echo "  ${output}/VCF/RTG_Raw/vcf_raw_summary.tsv"
echo "  ${output}/VCF/RTG_Pass/vcf_pass_summary.tsv"
echo "  ${output}/VCF/ANNOVAR/variant_category_summary.tsv"
echo ""
echo "Analysis completed at: $(date)"

