#!/bin/bash

# ================================================
# Quick Fix Script for Build Errors on VPS
# হাবিব ফার্নিচার - Build Error দ্রুত সমাধান
# ================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Build Error Quick Fix                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ package.json not found!${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Stop running application
echo -e "${YELLOW}[1/7] Stopping application...${NC}"
pm2 stop habib-furniture 2>/dev/null || echo "No running instance found"

# Clean node_modules and cache
echo -e "${YELLOW}[2/7] Cleaning old files...${NC}"
rm -rf node_modules package-lock.json .next
echo -e "${GREEN}✅ Cleaned${NC}"

# Clear npm cache
echo -e "${YELLOW}[3/7] Clearing npm cache...${NC}"
npm cache clean --force
echo -e "${GREEN}✅ Cache cleared${NC}"

# Install dependencies
echo -e "${YELLOW}[4/7] Installing dependencies...${NC}"
npm install
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ npm install failed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dependencies installed${NC}"

# Verify critical packages
echo -e "${YELLOW}[5/7] Verifying build packages...${NC}"
MISSING=""
for pkg in tailwindcss postcss autoprefixer typescript @prisma/client; do
    if [ ! -d "node_modules/$pkg" ]; then
        MISSING="$MISSING $pkg"
    fi
done

if [ -n "$MISSING" ]; then
    echo -e "${RED}❌ Missing packages:$MISSING${NC}"
    echo -e "${YELLOW}Installing missing packages...${NC}"
    npm install $MISSING
fi
echo -e "${GREEN}✅ All build packages present${NC}"

# Build application
echo -e "${YELLOW}[6/7] Building application...${NC}"
npm run build
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    echo ""
    echo -e "${YELLOW}Common fixes:${NC}"
    echo "1. Check .env file exists and has all required variables"
    echo "2. Verify DATABASE_URL is correct"
    echo "3. Run: npx prisma generate"
    echo ""
    exit 1
fi
echo -e "${GREEN}✅ Build successful${NC}"

# Restart application
echo -e "${YELLOW}[7/7] Restarting application...${NC}"
PORT=10000 pm2 restart habib-furniture || PORT=10000 pm2 start npm --name habib-furniture -- start
pm2 save
echo -e "${GREEN}✅ Application restarted${NC}"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Fix Completed! ✅                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Check status:${NC}"
echo "  pm2 status"
echo "  pm2 logs habib-furniture"
echo ""
echo -e "${BLUE}Test website:${NC}"
echo "  curl -I http://localhost:10000"
echo ""
