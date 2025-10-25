#!/usr/bin/env python3
"""
Alignment Stats Summary Script
================================
Parses samtools flagstat output files and generates an alignment summary.

Usage:
    python3 alignment_summary.py <bam_directory>

Example:
    python3 alignment_summary.py Analysis/BAM_Files
"""

import os
import glob
import pandas as pd
import sys

def main():
    # Check command line arguments
    if len(sys.argv) != 2:
        print("Usage: python3 alignment_summary.py <bam_directory>")
        print("\nExample:")
        print("  python3 alignment_summary.py Analysis/BAM_Files")
        sys.exit(1)
    
    stats_dir = sys.argv[1]
    
    # Check if directory exists
    if not os.path.exists(stats_dir):
        print(f"Error: Directory '{stats_dir}' does not exist!")
        sys.exit(1)
    
    print("=" * 60)
    print("Alignment Stats Summary")
    print("=" * 60)
    print(f"Input directory: {stats_dir}")
    print()
    
    # Find stats files
    stats_files = glob.glob(os.path.join(stats_dir, "*_alignSortStats.tsv"))
    
    if not stats_files:
        print(f"❌ No *_alignSortStats.tsv files found in '{stats_dir}'")
        print("\nExpected file pattern: *_alignSortStats.tsv")
        sys.exit(1)
    
    print(f"Found {len(stats_files)} alignment stats file(s)")
    print()
    
    # Parse files
    rows = []
    for filepath in sorted(stats_files):
        sample = os.path.basename(filepath).split('_alignSortStats.tsv')[0]
        print(f"Processing: {sample}...", end=" ")
        
        total_reads = None
        primary_mapped_reads = None
        primary_aligned_percentage = None
        
        try:
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
    out_file = os.path.join(stats_dir, "primary_mapped_summary.tsv")
    df.to_csv(out_file, sep="\t", index=False)
    
    print(f"✅ Alignment summary saved to: {out_file}")
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

