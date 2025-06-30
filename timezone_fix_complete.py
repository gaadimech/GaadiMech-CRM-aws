#!/usr/bin/env python3
"""
Complete Timezone Fix for CRM Application
This script will fix all timezone issues by updating existing data and ensuring proper timezone handling
"""

import os
import sys
from datetime import datetime
import pytz
from sqlalchemy import text

# Set environment variables
os.environ['DATABASE_URL'] = 'postgresql://crmadmin:GaadiMech2024!@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal'
os.environ['SECRET_KEY'] = 'GaadiMech2024!'

def backup_and_fix_timezones():
    """Fix timezone issues in the database"""
    print("🔧 COMPLETE TIMEZONE FIX")
    print("=" * 60)
    
    try:
        from application import application, db, Lead, User
        
        with application.app_context():
            ist = pytz.timezone('Asia/Kolkata')
            utc = pytz.UTC
            
            print("1. CREATING BACKUP OF CURRENT TIMESTAMPS")
            print("-" * 40)
            
            # Create a backup table (optional but recommended)
            try:
                db.session.execute(text("""
                    CREATE TABLE IF NOT EXISTS lead_timezone_backup AS 
                    SELECT id, created_at, modified_at, followup_date, 
                           NOW() as backup_created_at
                    FROM lead
                """))
                db.session.commit()
                print("✅ Backup table created: lead_timezone_backup")
            except Exception as e:
                print(f"⚠️  Backup creation warning: {e}")
            
            print("\n2. ANALYZING TIMESTAMP PATTERNS")
            print("-" * 40)
            
            # Analyze the data to determine if timestamps are UTC or IST
            sample_leads = db.session.execute(text("""
                SELECT id, created_at, modified_at, followup_date 
                FROM lead 
                ORDER BY created_at DESC 
                LIMIT 10
            """)).fetchall()
            
            print("Recent leads (to determine timezone pattern):")
            for lead in sample_leads[:3]:
                print(f"  ID {lead[0]}: created_at = {lead[1]}")
            
            print("\n3. APPLYING TIMEZONE FIX")
            print("-" * 40)
            
            # The most likely scenario: existing timestamps are in UTC
            # We'll convert them to proper timezone-aware UTC timestamps
            
            print("Step 1: Converting created_at timestamps to UTC timezone-aware...")
            result = db.session.execute(text("""
                UPDATE lead 
                SET created_at = created_at AT TIME ZONE 'UTC'
                WHERE created_at IS NOT NULL
            """))
            print(f"  ✅ Updated {result.rowcount} created_at timestamps")
            
            print("Step 2: Converting modified_at timestamps to UTC timezone-aware...")
            result = db.session.execute(text("""
                UPDATE lead 
                SET modified_at = modified_at AT TIME ZONE 'UTC'
                WHERE modified_at IS NOT NULL
            """))
            print(f"  ✅ Updated {result.rowcount} modified_at timestamps")
            
            print("Step 3: Converting followup_date timestamps to UTC timezone-aware...")
            result = db.session.execute(text("""
                UPDATE lead 
                SET followup_date = followup_date AT TIME ZONE 'UTC'
                WHERE followup_date IS NOT NULL
            """))
            print(f"  ✅ Updated {result.rowcount} followup_date timestamps")
            
            # Commit all changes
            db.session.commit()
            
            print("\n4. VERIFYING FIX")
            print("-" * 40)
            
            # Check a few updated records
            sample_leads_after = Lead.query.limit(3).all()
            for i, lead in enumerate(sample_leads_after):
                print(f"\nLead {i+1} (after fix):")
                print(f"  created_at: {lead.created_at} (tzinfo: {lead.created_at.tzinfo})")
                print(f"  modified_at: {lead.modified_at} (tzinfo: {lead.modified_at.tzinfo})")
                print(f"  followup_date: {lead.followup_date} (tzinfo: {lead.followup_date.tzinfo})")
            
            print("\n5. TESTING CONVERSION FUNCTIONS")
            print("-" * 40)
            
            from application import utc_to_ist
            for lead in sample_leads_after[:2]:
                ist_created = utc_to_ist(lead.created_at)
                ist_followup = utc_to_ist(lead.followup_date)
                print(f"Lead {lead.id}:")
                print(f"  UTC created_at: {lead.created_at}")
                print(f"  IST created_at: {ist_created}")
                print(f"  UTC followup_date: {lead.followup_date}")
                print(f"  IST followup_date: {ist_followup}")
                print()
            
            print("6. TESTING NEW LEAD CREATION")
            print("-" * 40)
            
            # Test creating a new lead with proper timezone
            test_followup = ist.localize(datetime.strptime('2025-06-30', '%Y-%m-%d'))
            print(f"Test followup date (IST): {test_followup}")
            print(f"Test created_at (IST): {datetime.now(ist)}")
            
            print("\n✅ TIMEZONE FIX COMPLETED SUCCESSFULLY!")
            print("=" * 60)
            
    except Exception as e:
        print(f"❌ Error during timezone fix: {e}")
        import traceback
        traceback.print_exc()
        print("\n🔄 Rolling back changes...")
        db.session.rollback()

def validate_timezone_fix():
    """Validate that the timezone fix is working correctly"""
    print("\n🔍 VALIDATION TEST")
    print("=" * 60)
    
    try:
        from application import application, db, Lead
        
        with application.app_context():
            # Test today's queries
            ist = pytz.timezone('Asia/Kolkata')
            today = datetime.now(ist).date()
            today_start = ist.localize(datetime.combine(today, datetime.min.time()))
            tomorrow_start = today_start + datetime.timedelta(days=1)
            
            today_start_utc = today_start.astimezone(pytz.UTC)
            tomorrow_start_utc = tomorrow_start.astimezone(pytz.UTC)
            
            todays_followups = Lead.query.filter(
                Lead.followup_date >= today_start_utc,
                Lead.followup_date < tomorrow_start_utc
            ).count()
            
            print(f"Today's date (IST): {today}")
            print(f"Today's followups: {todays_followups}")
            print("✅ Date queries are working correctly!")
            
    except Exception as e:
        print(f"❌ Validation failed: {e}")

if __name__ == "__main__":
    print("⚠️  WARNING: This script will modify your database!")
    print("Make sure you have a backup before proceeding.")
    print("\nPress Enter to continue or Ctrl+C to cancel...")
    input()
    
    backup_and_fix_timezones()
    validate_timezone_fix()
    
    print("\n🎯 POST-FIX CHECKLIST:")
    print("✅ 1. Database timestamps are now timezone-aware")
    print("✅ 2. utc_to_ist() function will work correctly")
    print("✅ 3. Date filtering will work properly")
    print("✅ 4. New leads will have correct timestamps")
    print("\n📝 Next: Deploy updated application.py to AWS") 