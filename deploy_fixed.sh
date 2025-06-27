#!/bin/bash

# GaadiMech CRM Dashboard Deployment Script (Fixed Version)
# This script deploys the fixed dashboard to AWS Elastic Beanstalk

set -e  # Exit on any error

echo "🚀 Starting GaadiMech CRM Dashboard Deployment (Fixed Version)"

# Check if we're in the right directory
if [ ! -f "application.py" ]; then
    echo "❌ Error: application.py not found. Please run this script from the project root."
    exit 1
fi

# Check if requirements_updated.txt exists
if [ ! -f "requirements_updated.txt" ]; then
    echo "❌ Error: requirements_updated.txt not found."
    exit 1
fi

echo "✅ Project files found"

# Create deployment directory
DEPLOY_DIR="deploy_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$DEPLOY_DIR"

echo "📦 Creating deployment package in $DEPLOY_DIR"

# Copy essential files for deployment
cp application.py "$DEPLOY_DIR/"
cp dashboard_optimized.py "$DEPLOY_DIR/"
cp requirements_updated.txt "$DEPLOY_DIR/requirements.txt"
cp -r templates "$DEPLOY_DIR/"

# Copy additional files if they exist
[ -f ".env" ] && cp .env "$DEPLOY_DIR/"
[ -f "Procfile" ] && cp Procfile "$DEPLOY_DIR/"

echo "✅ Files copied to deployment directory"

# Run tests before deployment
echo "🧪 Running pre-deployment tests..."
if python test_dashboard.py; then
    echo "✅ All tests passed"
else
    echo "❌ Tests failed. Aborting deployment."
    exit 1
fi

# Create deployment zip
cd "$DEPLOY_DIR"
zip -r "../${DEPLOY_DIR}.zip" .
cd ..

echo "✅ Deployment package created: ${DEPLOY_DIR}.zip"

# Check if EB CLI is available
if command -v eb &> /dev/null; then
    echo "🔧 EB CLI found. You can now deploy with:"
    echo "   eb deploy"
    echo ""
    echo "Or upload the zip file manually to AWS Elastic Beanstalk:"
    echo "   ${DEPLOY_DIR}.zip"
else
    echo "📋 EB CLI not found. Please upload the following file to AWS Elastic Beanstalk:"
    echo "   ${DEPLOY_DIR}.zip"
fi

echo ""
echo "🎉 Deployment package ready!"
echo ""
echo "📋 Deployment Instructions:"
echo "1. Upload ${DEPLOY_DIR}.zip to AWS Elastic Beanstalk"
echo "2. Ensure Python 3.13 runtime is selected"
echo "3. Set environment variables:"
echo "   - DATABASE_URL (optional, will use RDS_* variables if not set)"
echo "   - SECRET_KEY"
echo "   - RDS_HOST=gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com"
echo "   - RDS_DB=crmportal"
echo "   - RDS_USER=postgres"
echo "   - RDS_PASSWORD=GaadiMech2024!"
echo "   - RDS_PORT=5432"
echo ""
echo "4. After deployment, test the endpoints:"
echo "   - /health-check (should return status 200)"
echo "   - /login (should show login page)"
echo "   - /dashboard (should redirect to login)"
echo ""
echo "✨ Dashboard is ready for production!" 