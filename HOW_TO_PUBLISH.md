# How to Publish to GitHub

Step-by-step guide to publish the WES Analysis Pipeline to GitHub.

## Prerequisites

1. **GitHub Account**: Create one at https://github.com
2. **Git Installed**: Check with `git --version`
3. **All Files Ready**: Ensure all pipeline files are in the `WES_Pipeline_GitHub` directory

## Step 1: Create GitHub Repository

### Option A: Via GitHub Website

1. Go to https://github.com
2. Click the **"+"** icon → **"New repository"**
3. Fill in repository details:
   - **Repository name**: `WES-Analysis-Pipeline`
   - **Description**: `Comprehensive Whole Exome Sequencing analysis pipeline with parallel processing, QC, variant calling, and annotation`
   - **Public or Private**: Choose based on your needs
   - **Initialize**: DO NOT check "Add a README file" (we already have one)
4. Click **"Create repository"**

### Option B: Via GitHub CLI

```bash
gh repo create WES-Analysis-Pipeline --public --description "Comprehensive WES analysis pipeline"
```

## Step 2: Initialize Git Repository Locally

```bash
# Navigate to your pipeline directory
cd /home/nipladmin/Downloads/WES_Pipeline_GitHub

# Initialize git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: WES Analysis Pipeline v1.0.0"
```

## Step 3: Connect to GitHub and Push

```bash
# Add remote repository (replace 'yourusername' with your GitHub username)
git remote add origin https://github.com/yourusername/WES-Analysis-Pipeline.git

# Rename branch to main (if not already)
git branch -M main

# Push to GitHub
git push -u origin main
```

### If Using SSH (Alternative)

```bash
# Set up SSH key (if not already done)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add SSH key to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy and paste into GitHub Settings → SSH Keys

# Add remote with SSH
git remote add origin git@github.com:yourusername/WES-Analysis-Pipeline.git

# Push
git push -u origin main
```

## Step 4: Verify Upload

1. Go to `https://github.com/yourusername/WES-Analysis-Pipeline`
2. Verify all files are present:
   - ✅ README.md
   - ✅ WES_analysis_with_annovar.sh
   - ✅ Python scripts
   - ✅ LICENSE
   - ✅ All documentation files

## Step 5: Configure Repository Settings

### Add Topics (Tags)

1. Go to repository homepage
2. Click **"⚙️"** next to "About"
3. Add topics:
   - `bioinformatics`
   - `genomics`
   - `wes`
   - `whole-exome-sequencing`
   - `variant-calling`
   - `gatk`
   - `annovar`
   - `pipeline`
   - `bash`
   - `python`

### Update Description

Add a detailed description in the "About" section.

### Enable Issues

1. Go to **Settings** → **Features**
2. Enable **"Issues"**
3. Enable **"Discussions"** (optional, for Q&A)

## Step 6: Create Release (Optional)

### Create v1.0.0 Release

```bash
# Create and push a tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

Or via GitHub web interface:
1. Go to **Releases** → **"Draft a new release"**
2. Tag version: `v1.0.0`
3. Release title: `WES Analysis Pipeline v1.0.0`
4. Description: Copy from CHANGELOG.md
5. Click **"Publish release"**

## Step 7: Add README Badges (Optional)

Add badges to make your README more informative. Edit README.md:

```markdown
[![GitHub release](https://img.shields.io/github/v/release/yourusername/WES-Analysis-Pipeline)](https://github.com/yourusername/WES-Analysis-Pipeline/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/yourusername/WES-Analysis-Pipeline)](https://github.com/yourusername/WES-Analysis-Pipeline/issues)
[![GitHub stars](https://img.shields.io/github/stars/yourusername/WES-Analysis-Pipeline)](https://github.com/yourusername/WES-Analysis-Pipeline/stargazers)
```

## Step 8: Share Your Repository

### Get DOI with Zenodo (Recommended for Citations)

1. Go to https://zenodo.org
2. Link your GitHub account
3. Enable DOI generation for your repository
4. Create a new release
5. Zenodo will automatically archive and assign a DOI
6. Add DOI badge to README

### Share on Social Media

Share your repository with:
- Twitter/X (use hashtags: #bioinformatics #WES #genomics)
- LinkedIn
- Research Gate
- Relevant forums/communities

## Repository File Checklist

Before publishing, verify these files are present:

- [x] **WES_analysis_with_annovar.sh** - Main pipeline script
- [x] **alignment_summary.py** - Alignment summary script
- [x] **vcf_summary.py** - VCF summary script
- [x] **annovar_summary.py** - ANNOVAR summary script
- [x] **run_all_summaries.sh** - Master summary script
- [x] **README.md** - Main documentation
- [x] **QUICKSTART.md** - Quick start guide
- [x] **CHANGELOG.md** - Version history
- [x] **CONTRIBUTING.md** - Contribution guidelines
- [x] **LICENSE** - MIT License
- [x] **environment.yml** - Conda environment file
- [x] **.gitignore** - Git ignore file

## Maintaining Your Repository

### Regular Updates

```bash
# Make changes to files
git add .
git commit -m "Description of changes"
git push
```

### Responding to Issues

1. Monitor GitHub issues regularly
2. Label issues appropriately (bug, enhancement, question)
3. Respond promptly to questions
4. Close resolved issues

### Accepting Pull Requests

1. Review code changes carefully
2. Test the changes locally
3. Provide constructive feedback
4. Merge when satisfied

### Creating New Releases

For each new version:
1. Update CHANGELOG.md
2. Update version in README.md
3. Create and push a new tag
4. Create GitHub release

## Example: Complete Workflow

```bash
# One-time setup
cd /home/nipladmin/Downloads/WES_Pipeline_GitHub
git init
git add .
git commit -m "Initial commit: WES Analysis Pipeline v1.0.0"
git remote add origin https://github.com/yourusername/WES-Analysis-Pipeline.git
git branch -M main
git push -u origin main

# Create release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Future updates
git add <modified_files>
git commit -m "Fix: Update ANNOVAR path configuration"
git push

# View repository
echo "Repository published at:"
echo "https://github.com/yourusername/WES-Analysis-Pipeline"
```

## Troubleshooting

### Authentication Issues

```bash
# Use personal access token (PAT)
# Generate at: GitHub Settings → Developer settings → Personal access tokens
# Use token as password when pushing
```

### Push Rejected

```bash
# Pull latest changes first
git pull origin main --rebase
git push
```

### Large Files

```bash
# If you accidentally added large data files
git rm --cached large_file.fastq.gz
git commit -m "Remove large file"
git push
```

## Success! 🎉

Your WES Analysis Pipeline is now on GitHub and ready to:
- Share with collaborators
- Receive contributions
- Get citations
- Help the bioinformatics community

## Next Steps

1. **Star your own repository** (to test notifications)
2. **Create example dataset** (if possible, without sensitive data)
3. **Write blog post** about your pipeline
4. **Submit to awesome lists** (e.g., awesome-bioinformatics)
5. **Present at conferences** or lab meetings

---

**Questions?** Contact your.email@example.com or open an issue on GitHub!

