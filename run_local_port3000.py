#!/usr/bin/env python3
import os

# Set the DATABASE_URL to connect to our RDS with migrated Supabase data
os.environ['DATABASE_URL'] = 'postgresql://crmadmin:GaadiMech2024!@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal'
os.environ['FLASK_ENV'] = 'development'
os.environ['PORT'] = '3000'

# Import the app
from app import app

if __name__ == '__main__':
    print("🚀 Starting GaadiMech CRM locally...")
    print("📍 Database: crm-portal-db (AWS RDS)")
    print("📊 Data: 6,806 leads from Supabase migration")
    print("🌐 Server: http://localhost:3000")
    print("==================================================")
    
    # Run the app on port 3000
    app.run(host='0.0.0.0', port=3000, debug=True, use_reloader=False) 