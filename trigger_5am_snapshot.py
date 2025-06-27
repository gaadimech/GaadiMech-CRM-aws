#!/usr/bin/env python3
"""
Script to manually trigger the 5AM snapshot for testing
This will capture the current followup counts and fix them as today's baseline
"""

import os
import sys
from datetime import datetime

# Set environment variables
os.environ['DATABASE_URL'] = 'postgresql://crmadmin:GaadiMech2024!@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal'
os.environ['SECRET_KEY'] = 'GaadiMech2024!'

def trigger_snapshot():
    """Manually trigger the daily snapshot"""
    try:
        # Import application components
        from application import application, capture_daily_snapshot
        
        with application.app_context():
            print("🕐 Triggering manual 5AM snapshot...")
            print("=" * 50)
            
            # Run the snapshot function
            capture_daily_snapshot()
            
            print("✅ 5AM snapshot completed successfully!")
            print("=" * 50)
            print()
            print("What this did:")
            print("- Counted all leads with today's followup date")  
            print("- Stored these counts in DailyFollowupCount table")
            print("- Fixed today's baseline for dashboard metrics")
            print()
            print("Now you can:")
            print("1. Start the local server: python test_local_with_fixes.py")
            print("2. Test changing followup dates")
            print("3. Verify dashboard metrics stay fixed")
            
    except Exception as e:
        print(f"❌ Error triggering snapshot: {e}")
        sys.exit(1)

if __name__ == '__main__':
    trigger_snapshot() 