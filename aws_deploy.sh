#!/bin/bash

# AWS CRM Portal Deployment Script
echo "🚀 Starting AWS Deployment for CRM Portal..."

# Check if EB CLI is installed
if ! command -v eb &> /dev/null; then
    echo "❌ EB CLI not found. Installing..."
    pip install awsebcli
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites checked."

# Step 1: Initialize EB if not already done
if [ ! -d ".elasticbeanstalk" ]; then
    echo "📋 Initializing Elastic Beanstalk..."
    eb init --platform python-3.11 --region ap-south-1 crm-portal
else
    echo "✅ Elastic Beanstalk already initialized."
fi

# Step 2: Create environment if it doesn't exist
echo "🏗️  Creating/Updating production environment..."
eb create crm-production --single-instance || echo "Environment may already exist, continuing..."

# Step 3: Set environment variables
echo "🔧 Setting environment variables..."
echo "Please provide the following details:"

read -s -p "Enter SECRET_KEY: " SECRET_KEY
echo ""
read -s -p "Enter RDS_HOST (your RDS endpoint): " RDS_HOST
echo ""
read -s -p "Enter RDS_PASSWORD: " RDS_PASSWORD
echo ""

eb setenv SECRET_KEY="$SECRET_KEY"
eb setenv DATABASE_URL="postgresql://postgres:$RDS_PASSWORD@$RDS_HOST:5432/crmportal"
eb setenv RDS_HOST="$RDS_HOST"
eb setenv RDS_DB="crmportal"
eb setenv RDS_USER="postgres"
eb setenv RDS_PASSWORD="$RDS_PASSWORD"
eb setenv RDS_PORT="5432"
eb setenv FLASK_ENV="production"

# Step 4: Deploy application
echo "🚀 Deploying application..."
eb deploy

# Step 5: Check health and open
echo "🏥 Checking application health..."
eb health

echo "🌐 Opening application in browser..."
eb open

echo "✅ Deployment completed!"
echo "📊 Monitor your application:"
echo "  - Status: eb status"
echo "  - Logs: eb logs"
echo "  - Health: eb health --refresh" 