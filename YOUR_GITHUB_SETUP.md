# Your Personal GitHub Setup Guide

**Email**: snehagoel3142@gmail.com

## Step 1: Create GitHub Account (if you don't have one)

1. Go to https://github.com/signup
2. Use email: `snehagoel3142@gmail.com`
3. Choose a username (suggestions: `snehagoel`, `snehagoel3142`, `snehagoel-bioinformatics`)
4. Complete the signup process
5. Verify your email

## Step 2: Configure Git Locally

```bash
# Set your name and email for Git
git config --global user.name "Sneha Goel"
git config --global user.email "snehagoel3142@gmail.com"

# Verify configuration
git config --list
```

## Step 3: Create GitHub Repository

### Option A: Via GitHub Website (Easiest)

1. Go to https://github.com/new
2. Repository name: `WES-Analysis-Pipeline`
3. Description: `Comprehensive Whole Exome Sequencing analysis pipeline with parallel processing, QC, variant calling, and ANNOVAR annotation`
4. Select: **Public** (so others can use it)
5. **DO NOT** check "Add a README file" (we already have one)
6. Click **"Create repository"**

### Option B: Via Command Line (if you have GitHub CLI)

```bash
gh auth login
gh repo create WES-Analysis-Pipeline --public --description "Comprehensive WES analysis pipeline"
```

## Step 4: Initialize and Push Your Repository

```bash
# Navigate to your pipeline directory
cd /home/nipladmin/Downloads/WES_Pipeline_GitHub

# Initialize git repository
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: WES Analysis Pipeline v1.0.0

- Complete GATK best practices workflow
- Parallel processing (2 samples)
- Comprehensive QC and reporting
- ANNOVAR multi-database annotation
- Standalone summary scripts
- Full documentation"

# Add your GitHub repository as remote (REPLACE 'yourusername' with your actual GitHub username)
git remote add origin https://github.com/yourusername/WES-Analysis-Pipeline.git

# Rename branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

**IMPORTANT**: When prompted for username and password:
- Username: Your GitHub username
- Password: Use a **Personal Access Token** (not your GitHub password)

## Step 5: Create Personal Access Token (PAT)

GitHub no longer accepts passwords for command-line operations. You need a token:

1. Go to https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Note: `WES Pipeline Upload`
4. Expiration: Choose duration (90 days recommended)
5. Select scopes:
   - ✅ `repo` (all sub-options)
   - ✅ `workflow`
6. Click **"Generate token"**
7. **COPY THE TOKEN** (you won't see it again!)
8. Use this token as your password when pushing

## Step 6: Alternative - Use SSH (More Secure, No Password Needed)

### Set up SSH Key

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "snehagoel3142@gmail.com"

# Press Enter for default location
# Press Enter for no passphrase (or set one if you prefer)

# Copy your public key
cat ~/.ssh/id_ed25519.pub
```

### Add SSH Key to GitHub

1. Go to https://github.com/settings/ssh/new
2. Title: `WES Pipeline - Work Computer`
3. Paste your public key (from the cat command above)
4. Click **"Add SSH key"**

### Push with SSH

```bash
cd /home/nipladmin/Downloads/WES_Pipeline_GitHub

# If you already added HTTPS remote, remove it
git remote remove origin

# Add SSH remote (REPLACE 'yourusername')
git remote add origin git@github.com:yourusername/WES-Analysis-Pipeline.git

# Push
git push -u origin main
```

## Step 7: Verify Upload

1. Go to `https://github.com/yourusername/WES-Analysis-Pipeline`
2. You should see all 14 files
3. README.md should display automatically
4. Check that all scripts are present

## Step 8: Final Touches

### Add Topics/Tags

1. Go to your repository
2. Click **"⚙️"** next to "About"
3. Add topics:
   ```
   bioinformatics, genomics, wes, whole-exome-sequencing, 
   variant-calling, gatk, annovar, pipeline, bash, python
   ```

### Update Repository Description

In the "About" section:
```
Comprehensive WES analysis pipeline with parallel processing, quality control, 
GATK variant calling, and ANNOVAR annotation. Includes standalone summary 
scripts and full documentation.
```

### Update README with Your Info

Edit these files to replace placeholder information:

```bash
cd /home/nipladmin/Downloads/WES_Pipeline_GitHub

# Update README
sed -i 's/your.email@example.com/snehagoel3142@gmail.com/g' README.md
sed -i 's/yourusername/YOUR_GITHUB_USERNAME/g' README.md

# Commit changes
git add README.md
git commit -m "Update contact information"
git push
```

## Step 9: Create Your First Release

1. Go to your repository on GitHub
2. Click **"Releases"** → **"Draft a new release"**
3. Tag version: `v1.0.0`
4. Release title: `WES Analysis Pipeline v1.0.0`
5. Description:
   ```markdown
   # WES Analysis Pipeline v1.0.0
   
   First stable release of the Whole Exome Sequencing Analysis Pipeline.
   
   ## Features
   - Complete GATK best practices workflow
   - Parallel processing (2 samples simultaneously)
   - Comprehensive quality control (FastQC, MultiQC, SeqKit)
   - ANNOVAR multi-database variant annotation
   - Automated summary generation
   - Standalone Python scripts for flexible analysis
   
   ## What's Included
   - Main pipeline script
   - 4 standalone summary scripts
   - Comprehensive documentation
   - Quick start guide
   - Conda environment file
   
   See [README.md](README.md) for full documentation.
   ```
6. Click **"Publish release"**

## Complete Example Commands

Here's the complete workflow you can copy-paste:

```bash
# 1. Configure Git
git config --global user.name "Sneha Goel"
git config --global user.email "snehagoel3142@gmail.com"

# 2. Navigate to directory
cd /home/nipladmin/Downloads/WES_Pipeline_GitHub

# 3. Initialize repository
git init
git add .
git commit -m "Initial commit: WES Analysis Pipeline v1.0.0"

# 4. Add remote (REPLACE 'YOUR_USERNAME' with your actual GitHub username!)
git remote add origin https://github.com/YOUR_USERNAME/WES-Analysis-Pipeline.git

# 5. Push to GitHub
git branch -M main
git push -u origin main

# When prompted:
# Username: YOUR_GITHUB_USERNAME
# Password: YOUR_PERSONAL_ACCESS_TOKEN (not your GitHub password!)
```

## Troubleshooting

### "Authentication failed"
- Make sure you're using a Personal Access Token, not your GitHub password
- Generate token at: https://github.com/settings/tokens

### "Permission denied"
- For SSH: Make sure you added your SSH key to GitHub
- For HTTPS: Check your token has `repo` permissions

### "Remote already exists"
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/WES-Analysis-Pipeline.git
```

### "Nothing to commit"
```bash
# Make sure you're in the right directory
cd /home/nipladmin/Downloads/WES_Pipeline_GitHub
ls -la  # Should show all your pipeline files
```

## Next Steps After Publishing

1. ⭐ **Star your own repository** (to bookmark it)
2. 📝 **Update the README** with your specific paths and contact info
3. 🎓 **Share it**:
   - Twitter: "Just published my WES analysis pipeline! 🧬 #bioinformatics #genomics"
   - LinkedIn: Share with your network
   - Research Gate: Add to your publications
4. 📧 **Get a DOI** from Zenodo for citations
5. 🌟 **Wait for your first star from someone else!**

## Your Repository URLs (after creation)

- **Repository**: `https://github.com/YOUR_USERNAME/WES-Analysis-Pipeline`
- **Clone URL (HTTPS)**: `https://github.com/YOUR_USERNAME/WES-Analysis-Pipeline.git`
- **Clone URL (SSH)**: `git@github.com:YOUR_USERNAME/WES-Analysis-Pipeline.git`

## Getting Help

If you encounter issues:
1. Check GitHub's official guides: https://docs.github.com/en/get-started
2. Git basics: https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
3. GitHub community: https://github.community/

---

**Ready to publish!** 🚀

Just follow the steps above, and your pipeline will be live on GitHub!

**Questions?** Contact: snehagoel3142@gmail.com

