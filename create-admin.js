#!/usr/bin/env node

/**
 * Admin User Creation Script
 * Creates or updates an admin user in the database
 * 
 * Usage: node create-admin.js
 */

const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const readline = require('readline');

const prisma = new PrismaClient();

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(query) {
  return new Promise(resolve => rl.question(query, resolve));
}

async function main() {
  console.log('🔐 Admin User Creation\n');
  
  // Get user input
  const name = await question('Admin Name (default: Admin): ') || 'Admin';
  const phone = await question('Phone Number (e.g., 01700000000): ');
  
  if (!phone || phone.length !== 11 || !phone.startsWith('01')) {
    console.error('❌ Invalid phone number. Must be 11 digits starting with 01');
    process.exit(1);
  }
  
  const password = await question('Password (min 8 characters): ');
  
  if (!password || password.length < 8) {
    console.error('❌ Password must be at least 8 characters');
    process.exit(1);
  }
  
  console.log('\n⏳ Creating admin user...\n');
  
  // Hash password
  const passwordHash = await bcrypt.hash(password, 10);
  
  // Create or update admin user
  const admin = await prisma.user.upsert({
    where: { phone },
    update: {
      name,
      passwordHash,
      role: 'ADMIN'
    },
    create: {
      name,
      phone,
      passwordHash,
      role: 'ADMIN'
    }
  });
  
  console.log('✅ Admin user created successfully!\n');
  console.log('Login Details:');
  console.log(`  Phone: ${admin.phone}`);
  console.log(`  Password: ${password}`);
  console.log(`  Role: ${admin.role}`);
  console.log('\n🌐 Admin Panel: https://habibfurniture.com/admin/login\n');
  console.log('⚠️  Keep these credentials secure!\n');
}

main()
  .catch((error) => {
    console.error('❌ Error:', error.message);
    process.exit(1);
  })
  .finally(async () => {
    rl.close();
    await prisma.$disconnect();
  });
