#!/usr/bin/env python3
"""
Test script to verify database connection and show basic statistics
"""

import os
import sys
from datetime import datetime, timedelta

# Set environment variables
os.environ['DATABASE_URL'] = 'postgresql://crmadmin:GaadiMech2024!@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal'
os.environ['SECRET_KEY'] = 'GaadiMech2024!'

def test_connection():
    """Test database connection and show statistics"""
    try:
        from application import application, db, User, Lead, DailyFollowupCount
        import pytz
        
        ist = pytz.timezone('Asia/Kolkata')
        today = datetime.now(ist).date()
        
        with application.app_context():
            print("🔍 Testing Database Connection...")
            print("=" * 60)
            
            # Test basic connection
            result = db.session.execute(db.text('SELECT version()')).fetchone()
            db_version = result[0] if result else 'Unknown'
            print(f"✅ Database Connected: {db_version[:50]}...")
            
            # Get basic counts
            user_count = User.query.count()
            total_leads = Lead.query.count()
            
            print(f"📊 Users: {user_count}")
            print(f"📊 Total Leads: {total_leads}")
            
            # Get today's followup counts
            today_start = ist.localize(datetime.combine(today, datetime.min.time()))
            tomorrow_start = today_start + timedelta(days=1)
            
            today_start_utc = today_start.astimezone(pytz.UTC)
            tomorrow_start_utc = tomorrow_start.astimezone(pytz.UTC)
            
            todays_followups = Lead.query.filter(
                Lead.followup_date >= today_start_utc,
                Lead.followup_date < tomorrow_start_utc
            ).count()
            
            print(f"📅 Today's Followups: {todays_followups}")
            
            # Check if 5AM snapshot exists for today
            snapshot_count = DailyFollowupCount.query.filter_by(date=today).count()
            print(f"📸 5AM Snapshots for today: {snapshot_count}")
            
            if snapshot_count > 0:
                snapshots = DailyFollowupCount.query.filter_by(date=today).all()
                print("\n5AM Snapshot Details:")
                for snapshot in snapshots:
                    user = User.query.get(snapshot.user_id)
                    print(f"  - {user.name if user else 'Unknown'}: {snapshot.initial_count} followups")
            else:
                print("⚠️  No 5AM snapshot found for today. Run: python trigger_5am_snapshot.py")
            
            # Show user list
            users = User.query.all()
            print(f"\n👥 Users:")
            for user in users:
                print(f"  - {user.name} ({'Admin' if user.is_admin else 'User'})")
            
            print("\n" + "=" * 60)
            print("✅ Database connection test completed successfully!")
            print("\nNext steps:")
            print("1. python trigger_5am_snapshot.py  # Create today's snapshot")
            print("2. python test_local_with_fixes.py  # Start local server")
            
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        print("\nTroubleshooting:")
        print("- Check if the RDS database is accessible")
        print("- Verify database credentials")
        print("- Ensure network connectivity")
        sys.exit(1)

if __name__ == '__main__':
    test_connection() 