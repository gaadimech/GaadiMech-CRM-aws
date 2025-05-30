#!/usr/bin/env python3
"""
Supabase Setup Script for GaadiMech CRM
=======================================

This script initializes the Supabase database and creates all necessary tables.
"""

import os
import sys
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Check if DATABASE_URL is set
if not os.getenv('DATABASE_URL'):
    print("❌ DATABASE_URL environment variable is not set!")
    print("\nPlease set your Supabase database URL:")
    print("export DATABASE_URL='postgresql://postgres.[your-project-ref]:[your-password]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres'")
    sys.exit(1)

try:
    from app import app, db, User
    from sqlalchemy import text
    
    with app.app_context():
        print("🔧 Setting up Supabase database...")
        
        # Create all tables
        print("📋 Creating database tables...")
        db.create_all()
        print("✅ Database tables created successfully!")
        
        # Check if admin user exists
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            print("👤 Creating admin user...")
            admin = User(
                username='admin',
                name='Administrator',
                is_admin=True
            )
            admin.set_password('admin123')
            db.session.add(admin)
            
            # Create a test user
            test_user = User(
                username='test_user',
                name='Test User',
                is_admin=False
            )
            test_user.set_password('test123')
            db.session.add(test_user)
            
            db.session.commit()
            print("✅ Admin user created successfully!")
            print("   Username: admin")
            print("   Password: admin123")
            print("   Test User: test_user / test123")
        else:
            print("✅ Admin user already exists")
        
        # Test the connection
        result = db.session.execute(text('SELECT version()')).fetchone()
        print(f"✅ Database connection successful!")
        print(f"   Database Version: {result[0][:50]}...")
        
        # Count existing data
        user_count = User.query.count()
        print(f"   Users in database: {user_count}")
        
        from app import Lead
        lead_count = Lead.query.count()
        print(f"   Leads in database: {lead_count}")
        
        print("\n🎉 Supabase database setup complete!")
        print("🌐 You can now start your Flask application:")
        print("   python app.py")
        print("\n📱 Access your CRM at: http://localhost:8080")
        print("🔍 Test database connection at: http://localhost:8080/test_db")
        
except ImportError as e:
    print(f"❌ Import error: {e}")
    print("Make sure you've installed all dependencies:")
    print("pip install -r requirements.txt")
    sys.exit(1)
    
except Exception as e:
    print(f"❌ Database setup failed: {e}")
    print("\nTroubleshooting:")
    print("1. Check your DATABASE_URL is correct")
    print("2. Ensure your Supabase project is active")
    print("3. Verify network connectivity")
    print("4. Check Supabase project settings > Database")
    sys.exit(1) 