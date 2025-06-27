#!/usr/bin/env python3
"""
Local test script to run the CRM application with RDS database
This will test the fixed dashboard metrics that properly use 5AM snapshot data
"""

import os
import sys

# Set environment variables for local testing with RDS
os.environ['DATABASE_URL'] = 'postgresql://crmadmin:GaadiMech2024!@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal'
os.environ['FLASK_ENV'] = 'development'
os.environ['PORT'] = '3000'
os.environ['SECRET_KEY'] = 'GaadiMech2024!'

# Import the application
from application import application

if __name__ == '__main__':
    print("🚀 Starting GaadiMech CRM with FIXED Dashboard Metrics...")
    print("=" * 60)
    print("📍 Database: AWS RDS (crm-portal-db)")
    print("📊 Data: Connected to production database")
    print("🌐 Server: http://localhost:3000")
    print("=" * 60)
    print()
    print("FIXES APPLIED:")
    print("✅ Today's Followups: Fixed at 5AM snapshot")
    print("✅ Currently Pending: Total Fixed at 5AM - Total Worked")
    print("✅ Completion Rate: Worked Upon / Total Fixed at 5AM")
    print("✅ Team Performance: Assigned/Worked/Pending calculations")
    print("=" * 60)
    print()
    print("Testing Instructions:")
    print("1. Login to the dashboard")
    print("2. Check 'Today's Followups' metric (should be fixed)")
    print("3. Change a followup date from today to future")
    print("4. Verify 'Today's Followups' count doesn't decrease")
    print("5. Check 'Currently Pending' calculation") 
    print("6. Verify Team Performance - Daily Progress updates")
    print("=" * 60)
    
    try:
        # Create tables if they don't exist
        with application.app_context():
            from application import db
            db.create_all()
            print("✅ Database tables ready")
        
        # Run the application
        application.run(host='0.0.0.0', port=3000, debug=True, use_reloader=False)
        
    except Exception as e:
        print(f"❌ Error starting application: {e}")
        sys.exit(1) 