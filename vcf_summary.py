#!/usr/bin/env python3
"""
VCF Stats Summary Script
==========================
Parses RTG vcfstats output files and generates a VCF summary.

Usage:
    python3 vcf_summary.py <rtg_stats_directory> <output_type>

Arguments:
    rtg_stats_directory: Directory containing RTG stats files
    output_type: Either 'raw' or 'pass'

Examples:
    python3 vcf_summary.py Analysis/VCF/RTG_Raw raw
    python3 vcf_summary.py Analysis/VCF/RTG_Pass pass
"""

import os
import glob
import pandas as pd
import sys

def main():
    # Check command line arguments
    if len(sys.argv) != 3:
        print("Usage: python3 vcf_summary.py <rtg_stats_directory> <output_type>")
        print("\nArguments:")
        print("  rtg_stats_directory: Directory containing RTG stats files")
        print("  output_type: Either 'raw' or 'pass'")
        print("\nExamples:")
        print("  python3 vcf_summary.py Analysis/VCF/RTG_Raw raw")
        print("  python3 vcf_summary.py Analysis/VCF/RTG_Pass pass")
        sys.exit(1)
    
    stats_dir = sys.argv[1]
    output_type = sys.argv[2].lower()
    
    # Validate output type
    if output_type not in ['raw', 'pass']:
        print(f"Error: output_type must be 'raw' or 'pass', got '{output_type}'")
        sys.exit(1)
    
    # Check if directory exists
    if not os.path.exists(stats_dir):
        print(f"Error: Directory '{stats_dir}' does not exist!")
        sys.exit(1)
    
    print("=" * 60)
    print(f"VCF Stats Summary ({output_type.upper()})")
    print("=" * 60)
    print(f"Input directory: {stats_dir}")
    print()
    
    # Determine file pattern based on output type
    if output_type == 'raw':
        pattern = "*_rtg_stats.txt"
        suffix = "_rtg_stats.txt"
        out_filename = "vcf_raw_summary.tsv"
    else:  # pass
        pattern = "*_pass_rtg_stats.txt"
        suffix = "_pass_rtg_stats.txt"
        out_filename = "vcf_pass_summary.tsv"
    
    # Find stats files
    stats_files = glob.glob(os.path.join(stats_dir, pattern))
    
    if not stats_files:
        print(f"❌ No RTG stats files found in {stats_dir}")
        print(f"   Expected pattern: {pattern}")
        sys.exit(1)
    
    print(f"Found {len(stats_files)} VCF stats file(s)")
    print()
    
    rows = []
    for filepath in sorted(stats_files):
        sample = os.path.basename(filepath).replace(suffix, "")
        print(f"Processing: {sample}...", end=" ")
        
        passed = snps = ins = dels = indels = het_hom = None
        
        try:
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
            print("✓")
            
        except Exception as e:
            print(f"❌ Error: {e}")
            rows.append({
                "Sample": sample,
                "Error": str(e)
            })
    
    print()
    print("=" * 60)
    
    # Save results
    df = pd.DataFrame(rows)
    df = df.sort_values(by="Sample").reset_index(drop=True)
    out_file = os.path.join(stats_dir, out_filename)
    df.to_csv(out_file, sep="\t", index=False)
    
    print(f"✅ {output_type.upper()} VCF summary saved to: {out_file}")
    print()
    print("Summary Table:")
    print("-" * 60)
    print(df.to_string(index=False))
    print()
    print("=" * 60)
    print("Analysis Complete!")
    print("=" * 60)

if __name__ == "__main__":
    main()

