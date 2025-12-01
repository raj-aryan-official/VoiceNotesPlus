# Deployment Guide for Vercel

## Option 1: Manual Deployment (Recommended)

Since Vercel doesn't natively support Flutter builds, you need to build locally first:

### Steps:

1. **Build the web app:**
   ```bash
   flutter build web --release
   ```

2. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

3. **Deploy the build folder:**
   ```bash
   cd build/web
   vercel --prod
   ```

4. **Or deploy from root:**
   ```bash
   vercel --prod build/web
   ```

## Option 2: GitHub Actions (Automatic)

The repository includes a GitHub Actions workflow (`.github/workflows/vercel-deploy.yml`) that will:
- Build the Flutter web app automatically
- Deploy to Vercel on every push to main

### Setup:

1. Go to Vercel Dashboard → Settings → General
2. Copy your:
   - VERCEL_TOKEN
   - VERCEL_ORG_ID  
   - VERCEL_PROJECT_ID

3. Add these as GitHub Secrets:
   - Go to your GitHub repo → Settings → Secrets and variables → Actions
   - Add the three secrets above

4. Push to main branch - deployment will happen automatically!

## Option 3: Vercel Dashboard

1. Build the app locally:
   ```bash
   flutter build web --release
   ```

2. Go to [Vercel Dashboard](https://vercel.com/dashboard)
3. Click "Add New Project"
4. Import your GitHub repository
5. Set:
   - **Framework Preset:** Other
   - **Root Directory:** `build/web`
   - **Build Command:** `flutter build web --release` (or leave empty if building locally)
   - **Output Directory:** `build/web`

**Note:** Since Vercel doesn't have Flutter SDK, you'll need to build locally and commit the `build/web` folder, or use GitHub Actions.

## Recommended: Use GitHub Actions

The easiest way is to use the included GitHub Actions workflow which builds and deploys automatically!


