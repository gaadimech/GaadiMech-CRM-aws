#!/bin/bash

# AWS Deployment Script for GaadiMech CRM
# This script will guide you through the complete AWS deployment process

echo "🚀 GaadiMech CRM - AWS Deployment Script"
echo "========================================"

# Phase 1: Check prerequisites
echo "📋 Phase 1: Checking prerequisites..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run: aws configure"
    echo "You need Access Key ID and Secret Access Key from AWS Console"
    exit 1
fi

echo "✅ AWS CLI configured"

# Check if EB CLI is available
if ! command -v eb &> /dev/null; then
    echo "❌ EB CLI not found. Installing..."
    pipx install awsebcli
    echo "✅ EB CLI installed"
else
    echo "✅ EB CLI available"
fi

# Phase 2: Environment Variables Setup
echo ""
echo "🔧 Phase 2: Setting up environment variables..."

# Create a local .env file for AWS deployment
cat > .env << EOL
# AWS RDS Configuration
# IMPORTANT: Replace these values with your actual RDS details
SECRET_KEY=GaadiMech-Super-Secret-Key-Change-This-2024
DATABASE_URL=postgresql://postgres:GaadiMech2024!@gaadimech-crm-db.xxxxx.ap-south-1.rds.amazonaws.com:5432/crmportal
RDS_HOST=gaadimech-crm-db.xxxxx.ap-south-1.rds.amazonaws.com
RDS_DB=crmportal
RDS_USER=postgres
RDS_PASSWORD=GaadiMech2024!
RDS_PORT=5432
FLASK_ENV=production
EOL

echo "✅ Environment file created (.env)"
echo "⚠️  IMPORTANT: Update the RDS endpoint in .env with your actual database endpoint!"

# Phase 3: Elastic Beanstalk Setup
echo ""
echo "🚀 Phase 3: Elastic Beanstalk Setup..."

echo "Run the following commands manually:"
echo ""
echo "1. Initialize EB application:"
echo "   eb init"
echo "   - Choose region: 6 (ap-south-1)"
echo "   - Application name: gaadimech-crm"
echo "   - Platform: Python 3.11"
echo "   - CodeCommit: N"
echo "   - SSH: Y"
echo ""
echo "2. Create EB environment with t3.micro:"
echo "   eb create gaadimech-crm-prod --instance-types t3.micro"
echo ""
echo "3. Set environment variables:"
echo "   eb setenv SECRET_KEY=\"GaadiMech-Super-Secret-Key-Change-This-2024\""
echo "   eb setenv DATABASE_URL=\"postgresql://postgres:GaadiMech2024!@YOUR-RDS-ENDPOINT:5432/crmportal\""
echo "   eb setenv FLASK_ENV=\"production\""
echo ""
echo "4. Deploy application:"
echo "   eb deploy"
echo ""
echo "5. Open application:"
echo "   eb open"

echo ""
echo "📝 Next Steps:"
echo "1. Create RDS database (see detailed guide below)"
echo "2. Update .env with actual RDS endpoint"
echo "3. Run the EB commands above"
echo ""

# Phase 4: Database Setup Instructions
echo ""
echo "🗄️ Phase 4: RDS Database Setup Instructions"
echo "============================================"
echo ""
echo "Go to AWS Console → RDS → Create Database:"
echo ""
echo "Engine: PostgreSQL"
echo "Template: Free tier (if eligible) or Dev/Test"
echo "DB instance identifier: gaadimech-crm-db"
echo "Master username: postgres"
echo "Master password: GaadiMech2024!"
echo "DB instance class: db.t3.micro"
echo "Storage: 20 GiB General Purpose SSD"
echo "Public access: Yes"
echo "Initial database name: crmportal"
echo ""
echo "Security Group (after creation):"
echo "- Go to EC2 → Security Groups"
echo "- Find your DB security group"
echo "- Add inbound rule: PostgreSQL (5432) from 0.0.0.0/0"
echo ""

echo "✅ Deployment script completed!"
echo "📖 Follow the manual steps above to complete deployment" 