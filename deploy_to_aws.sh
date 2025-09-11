#!/bin/bash

echo "=== GaadiMech CRM AWS Deployment Script ==="
echo "Date: 25th August 2025"
echo "Environment: gaadimech-production"
echo ""

# Check if deployment file exists
if [ ! -f "gaadimech_crm_deployment_25th_august.zip" ]; then
    echo "ERROR: Deployment file not found!"
    echo "Please ensure gaadimech_crm_deployment_25th_august.zip exists in the current directory."
    exit 1
fi

echo "Deployment file found: gaadimech_crm_deployment_25th_august.zip"
echo "File size: $(du -h gaadimech_crm_deployment_25th_august.zip | cut -f1)"
echo ""

echo "=== DEPLOYMENT OPTIONS ==="
echo "1. Upload via AWS Console (Recommended)"
echo "   - Go to AWS Elastic Beanstalk Console"
echo "   - Select environment: gaadimech-production"
echo "   - Click 'Upload and Deploy'"
echo "   - Select: gaadimech_crm_deployment_25th_august.zip"
echo ""
echo "2. Deploy via EB CLI"
echo "   - Run: eb deploy --version-label gaadimech-25th-august"
echo ""

echo "=== DEPLOYMENT CONTENTS ==="
echo "✓ Main application (application.py)"
echo "✓ All templates and static files"
echo "✓ Optimized nginx configuration"
echo "✓ Database migrations"
echo "✓ Environment configurations"
echo "✓ Text parser utilities"
echo ""

echo "=== IMPORTANT NOTES ==="
echo "• Environment: gaadimech-production"
echo "• Platform: Python 3.11"
echo "• Region: ap-south-1"
echo "• Database: PostgreSQL RDS"
echo ""

echo "Ready for deployment!"

