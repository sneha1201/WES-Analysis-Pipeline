#!/usr/bin/env python3
"""
ANNOVAR Variant Category Summary Script
========================================
Parses ANNOVAR .hg38_multianno.txt files and generates a summary of variant categories.

Usage:
    python3 annovar_summary.py <annovar_directory>

Example:
    python3 annovar_summary.py Analysis/VCF/ANNOVAR
"""

import pandas as pd
import glob
import os
import sys

def main():
    # Check command line arguments
    if len(sys.argv) != 2:
        print("Usage: python3 annovar_summary.py <annovar_directory>")
        print("\nExample:")
        print("  python3 annovar_summary.py Analysis/VCF/ANNOVAR")
        sys.exit(1)
    
    annovar_dir = sys.argv[1]
    
    # Check if directory exists
    if not os.path.exists(annovar_dir):
        print(f"Error: Directory '{annovar_dir}' does not exist!")
        sys.exit(1)
    
    print("=" * 60)
    print("ANNOVAR Variant Category Summary")
    print("=" * 60)
    print(f"Input directory: {annovar_dir}")
    print()
    
    # Find all ANNOVAR output files
    tsv_files = glob.glob(os.path.join(annovar_dir, "*.hg38_multianno.txt"))
    
    if not tsv_files:
        print(f"❌ No ANNOVAR .hg38_multianno.txt files found in {annovar_dir}")
        print("\nExpected file pattern: *_annovar.vcf.hg38_multianno.txt")
        sys.exit(1)
    
    print(f"Found {len(tsv_files)} ANNOVAR annotation file(s)")
    print()
    
    results = []
    
    for file in sorted(tsv_files):
        # Extract sample name (before '_annovar.vcf...')
        sample = os.path.basename(file).split('_annovar.vcf')[0]
        print(f"Processing: {sample}...", end=" ")
        
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
                    "exonic": int((df["Func.ensGene"] == "exonic").sum()),
                    "intronic": int((df["Func.ensGene"] == "intronic").sum()),
                    "upstream": int((df["Func.ensGene"] == "upstream").sum()),
                    "downstream": int((df["Func.ensGene"] == "downstream").sum()),
                    "UTR3": int((df["Func.ensGene"] == "UTR3").sum()),
                    "UTR5": int((df["Func.ensGene"] == "UTR5").sum()),
                    "splicing": int((df["Func.ensGene"] == "splicing").sum()),
                    "ncRNA_exonic": int((df["Func.ensGene"] == "ncRNA_exonic").sum()),
                    "ncRNA_intronic": int((df["Func.ensGene"] == "ncRNA_intronic").sum()),
                    "intergenic": int((df["Func.ensGene"] == "intergenic").sum())
                }
                print(f"✓ ({total} variants)")
            else:
                counts = {
                    "Sample": sample,
                    "Total_Variants": total,
                    "Note": "Func.ensGene column not found"
                }
                print(f"⚠ Func.ensGene column not found")
            
            results.append(counts)
            
        except Exception as e:
            print(f"❌ Error: {e}")
            results.append({
                "Sample": sample,
                "Error": str(e)
            })
    
    print()
    print("=" * 60)
    
    # Combine all results into one table
    summary_df = pd.DataFrame(results)
    summary_df = summary_df.sort_values(by="Sample").reset_index(drop=True)
    
    # Save to TSV
    out_file = os.path.join(annovar_dir, "variant_category_summary.tsv")
    summary_df.to_csv(out_file, sep="\t", index=False)
    
    print(f"✅ ANNOVAR summary saved to: {out_file}")
    print()
    print("Summary Table:")
    print("-" * 60)
    print(summary_df.to_string(index=False))
    print()
    print("=" * 60)
    print("Analysis Complete!")
    print("=" * 60)

if __name__ == "__main__":
    main()

