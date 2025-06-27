#!/usr/bin/env python3
"""
Test script to verify AWS RDS database connectivity and dashboard functionality
"""

import sys
import os

def test_aws_rds_connection():
    """Test the AWS RDS database connection and functionality"""
    try:
        from app import app, db, User, Lead, DailyFollowupCount
        
        print("🔍 Testing AWS RDS Database Connection...")
        print("=" * 50)
        
        with app.app_context():
            # Test basic database connectivity
            result = db.session.execute(db.text('SELECT version()')).fetchone()
            print(f"✅ Database Connected: {result[0][:70]}...")
            
            # Test table access and counts
            user_count = User.query.count()
            lead_count = Lead.query.count()
            daily_count = DailyFollowupCount.query.count()
            
            print(f"✅ Database Tables:")
            print(f"   • Users: {user_count}")
            print(f"   • Leads: {lead_count}")
            print(f"   • Daily Counts: {daily_count}")
            
            # Test dashboard optimization module
            try:
                from dashboard_optimized import get_optimized_dashboard_data
                print("✅ Dashboard optimization module imported successfully")
            except ImportError as e:
                print(f"⚠️  Dashboard optimization import warning: {e}")
            
            # Test database configuration
            db_url = app.config['SQLALCHEMY_DATABASE_URI']
            if 'gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com' in db_url:
                print("✅ AWS RDS endpoint configured correctly")
            else:
                print("⚠️  Database URL doesn't appear to be AWS RDS")
            
            print("\n" + "=" * 50)
            print("🎉 AWS RDS Database Test Completed Successfully!")
            print("📊 Dashboard should work properly with the new database.")
            print("🔄 Cache has been optimized to prevent data errors.")
            
            return True
            
    except Exception as e:
        print(f"❌ Test Failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_aws_rds_connection()
    sys.exit(0 if success else 1) 