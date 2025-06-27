#!/bin/bash

echo "🚀 GaadiMech CRM - Quick Clean Deployment Script"
echo "================================================"

# Check if EB CLI is installed
if ! command -v eb &> /dev/null; then
    echo "❌ EB CLI not found. Please install it first:"
    echo "pip install awsebcli"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Initialize EB if not already done
if [ ! -f ".elasticbeanstalk/config.yml" ]; then
    echo "🔧 Initializing Elastic Beanstalk..."
    echo "Please follow the prompts:"
    echo "- Region: 6 (ap-south-1)"
    echo "- Application name: gaadimech-crm-clean"
    echo "- Platform: Python 3.11"
    echo "- CodeCommit: N"
    echo "- SSH keypair: Y"
    
    eb init
    
    if [ $? -ne 0 ]; then
        echo "❌ EB initialization failed"
        exit 1
    fi
fi

# Create environment
echo "🚀 Creating new environment..."
echo "This will take 10-15 minutes..."

eb create gaadimech-crm-prod-new --instance-types t3.micro

if [ $? -ne 0 ]; then
    echo "❌ Environment creation failed"
    exit 1
fi

echo "✅ Environment created successfully!"

# Set environment variables
echo "🔧 Setting environment variables..."

eb setenv \
    SECRET_KEY="GaadiMech-Super-Secret-Key-Change-This-2024" \
    DATABASE_URL="postgresql://postgres:GaadiMech2024!@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal" \
    RDS_HOST="crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com" \
    RDS_DB="crmportal" \
    RDS_USER="postgres" \
    RDS_PASSWORD="GaadiMech2024!" \
    RDS_PORT="5432" \
    FLASK_ENV="production"

if [ $? -ne 0 ]; then
    echo "❌ Failed to set environment variables"
    exit 1
fi

echo "✅ Environment variables set successfully!"

# Deploy application
echo "🚀 Deploying application..."
echo "This will take 5-10 minutes..."

eb deploy

if [ $? -ne 0 ]; then
    echo "❌ Deployment failed"
    echo "Check logs with: eb logs"
    exit 1
fi

echo "✅ Deployment completed successfully!"

# Get application URL
APP_URL=$(eb status | grep "CNAME" | awk '{print $2}')

echo ""
echo "🎉 Deployment Complete!"
echo "======================"
echo "Application URL: https://$APP_URL"
echo ""
echo "📋 Next Steps:"
echo "1. Test your application: eb open"
echo "2. Check database connection: https://$APP_URL/test_db"
echo "3. View logs if needed: eb logs"
echo ""
echo "🔧 Troubleshooting:"
echo "- If database connection fails, check RDS security group"
echo "- Verify environment variables: eb printenv"
echo ""

# Open application
read -p "Open application in browser now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    eb open
fi 