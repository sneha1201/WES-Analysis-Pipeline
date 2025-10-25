# Contributing to WES Analysis Pipeline

Thank you for your interest in contributing to the WES Analysis Pipeline! This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the problem
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Environment details**:
  - OS version
  - Tool versions (GATK, BWA, etc.)
  - Python version
  - Sample size and characteristics

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case** and motivation
- **Proposed solution** or implementation approach
- **Alternatives considered**

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes**:
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation as needed
3. **Test your changes**:
   - Run the pipeline with test data
   - Verify all outputs are generated correctly
   - Check summary scripts work independently
4. **Update CHANGELOG.md** with your changes
5. **Submit a pull request** with:
   - Clear title and description
   - Link to related issues
   - Screenshots/examples (if applicable)

## Development Guidelines

### Code Style

#### Bash Scripts

```bash
# Use descriptive variable names
sample_name="Sample1"
output_directory="/path/to/output"

# Add comments for complex sections
# --- This section performs quality control ---

# Use error handling
set -e  # Exit on error
set -o pipefail  # Catch errors in pipes

# Use functions for repeated code
process_sample() {
    local sample=$1
    # Process sample
}
```

#### Python Scripts

```python
# Follow PEP 8 style guide
# Use docstrings
def parse_stats_file(filepath):
    """
    Parse alignment statistics file.
    
    Args:
        filepath (str): Path to stats file
        
    Returns:
        dict: Parsed statistics
    """
    # Implementation
```

### Testing

Before submitting changes:

1. **Test with small dataset**: Verify basic functionality
2. **Test with full dataset**: Ensure scalability
3. **Test edge cases**: Empty files, missing data, etc.
4. **Test standalone scripts**: Verify they work independently

### Documentation

- Update README.md for new features
- Add examples for new functionality
- Update QUICKSTART.md if needed
- Comment complex code sections

## Project Structure

```
WES_Pipeline_GitHub/
├── WES_analysis_with_annovar.sh  # Main pipeline script
├── alignment_summary.py           # Alignment statistics
├── vcf_summary.py                 # VCF statistics
├── annovar_summary.py             # ANNOVAR summary
├── run_all_summaries.sh          # Master summary script
├── README.md                      # Main documentation
├── QUICKSTART.md                  # Quick start guide
├── CHANGELOG.md                   # Version history
├── CONTRIBUTING.md                # This file
├── LICENSE                        # MIT License
├── environment.yml                # Conda environment
└── .gitignore                     # Git ignore rules
```

## Feature Requests

We welcome feature requests! Priority areas include:

1. **Performance Improvements**
   - Faster processing
   - Better resource utilization
   - Parallel optimization

2. **Additional Features**
   - CNV calling
   - Structural variants
   - Joint genotyping
   - Custom filtering profiles

3. **Usability Enhancements**
   - Configuration file support
   - Resume functionality
   - Better error messages
   - Progress bars

4. **Integration**
   - Docker support
   - Singularity support
   - Workflow managers (Nextflow, Snakemake)

## Questions?

Feel free to:
- Open an issue for questions
- Start a discussion in GitHub Discussions
- Contact the maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Acknowledgments

Contributors will be acknowledged in:
- README.md
- CHANGELOG.md
- GitHub contributors page

Thank you for contributing! 🎉

