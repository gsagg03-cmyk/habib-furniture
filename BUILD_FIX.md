# Build Error Fix Guide

## সমস্যা (Problems)

VPS এ build করার সময় এই error গুলো আসতে পারে:

```
Module not found: Can't resolve '@/context/CartContext'
Cannot find module 'tailwindcss'
```

## কারণ (Root Causes)

1. **devDependencies install হয়নি** - Production build করার জন্য tailwindcss, postcss লাগে
2. **node_modules corrupt** - Cache বা incomplete install
3. **package-lock.json মিসম্যাচ** - Local এবং server এ version different

## সমাধান (Solutions)

### Method 1: Clean Install (সবচেয়ে নিরাপদ)

```bash
cd /var/www/habib-furniture

# Remove old modules and cache
rm -rf node_modules package-lock.json
npm cache clean --force

# Fresh install with ALL dependencies
npm install

# Build
npm run build
```

### Method 2: Force Install devDependencies

```bash
cd /var/www/habib-furniture

# Install everything (not just production)
npm install

# Or explicitly install build dependencies
npm install tailwindcss postcss autoprefixer typescript tsx --save-dev

# Build
npm run build
```

### Method 3: Use Setup Script

```bash
cd /var/www/habib-furniture

# Pull latest code
git pull origin main

# Run production setup (handles everything)
npm run setup:prod
```

## VPS এ সঠিক Deployment Steps

### Step 1: Clone Repository
```bash
cd /var/www
git clone https://github.com/gsagg03-cmyk/habib-furniture.git
cd habib-furniture
```

### Step 2: Install Dependencies
```bash
# IMPORTANT: Install ALL dependencies (not --production)
npm install

# Verify critical packages
npm list tailwindcss postcss autoprefixer
```

### Step 3: Configure Environment
```bash
cp .env.production.example .env
nano .env
# Fill in all required values
```

### Step 4: Setup Database
```bash
npx prisma migrate deploy
npx prisma generate
npx prisma db seed
```

### Step 5: Build Application
```bash
# This needs devDependencies installed
npm run build
```

### Step 6: Start Application
```bash
PORT=10000 pm2 start npm --name habib-furniture -- start
pm2 save
```

## Common Mistakes (এড়িয়ে চলুন)

### ❌ Wrong: Installing only production dependencies
```bash
npm install --production  # DON'T DO THIS!
```

### ✅ Correct: Installing all dependencies
```bash
npm install  # This includes devDependencies needed for build
```

### ❌ Wrong: Not cleaning cache when errors occur
```bash
npm install  # Just retrying won't fix cache issues
```

### ✅ Correct: Clean cache first
```bash
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

## Verification Commands

Check if build dependencies are installed:

```bash
# Check Node version
node --version  # Should be v20+

# Check if packages exist
ls node_modules/tailwindcss
ls node_modules/postcss
ls node_modules/@prisma/client

# List installed packages
npm list --depth=0

# Verify build
npm run build
```

## Updated Scripts

The following scripts have been updated to handle these issues:

1. **scripts/setup-production.sh**
   - Auto-clears cache on install failure
   - Retries installation
   - Better error messages

2. **scripts/ubuntu-setup.sh**
   - Installs all dependencies (not just production)
   - Cache clean on failure
   - Verification steps

## Quick Fix (যদি এখনই ঠিক করতে চান)

If you're on VPS right now and getting build errors:

```bash
# Go to project directory
cd /var/www/habib-furniture

# Stop any running instance
pm2 stop habib-furniture

# Clean everything
rm -rf node_modules package-lock.json .next

# Fresh install
npm cache clean --force
npm install

# Rebuild
npm run build

# Restart
PORT=10000 pm2 restart habib-furniture
```

## Prevention (ভবিষ্যতে এড়াতে)

1. **Always commit package-lock.json** to git
2. **Don't use `--production` flag** when building on server
3. **Keep devDependencies** - they're needed for build
4. **Use setup scripts** instead of manual steps
5. **Verify node version** matches (v20+)

## Understanding devDependencies

These packages are in `devDependencies` but **REQUIRED for build**:

- `tailwindcss` - CSS framework
- `postcss` - CSS processor
- `autoprefixer` - CSS vendor prefixes
- `typescript` - Type checking
- `tsx` - Running TypeScript scripts
- `prisma` - Database CLI

**তাই production server এও এগুলো install করতে হবে!**

## Need Help?

1. Check this guide first
2. Run `npm run health-check`
3. Check logs: `pm2 logs habib-furniture`
4. Verify .env configuration

---

**Last Updated**: January 4, 2026  
**Status**: Scripts updated to auto-fix common issues
