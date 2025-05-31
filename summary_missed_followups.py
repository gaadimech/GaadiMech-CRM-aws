#!/usr/bin/env python3
"""
Summary of Missed Follow-ups Report

This script provides a concise summary of missed follow-ups grouped by date.
"""

import os
from datetime import datetime, date
from collections import defaultdict
from sqlalchemy import create_engine, text

def get_database_url():
    """Get the database URL using the same logic as the main Flask app."""
    DATABASE_URL = os.getenv("DATABASE_URL")

    if not DATABASE_URL:
        SUPABASE_HOST = os.getenv("SUPABASE_HOST", "aws-0-ap-south-1.pooler.supabase.com")
        SUPABASE_DB = os.getenv("SUPABASE_DB", "postgres")
        SUPABASE_USER = os.getenv("SUPABASE_USER", "postgres.qcvfmiqzkfhinxlhknnd")
        SUPABASE_PASSWORD = os.getenv("SUPABASE_PASSWORD", "gaadimech123")
        SUPABASE_PORT = os.getenv("SUPABASE_PORT", "6543")
        
        DATABASE_URL = f"postgresql://{SUPABASE_USER}:{SUPABASE_PASSWORD}@{SUPABASE_HOST}:{SUPABASE_PORT}/{SUPABASE_DB}"

    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    
    return DATABASE_URL

def get_missed_followups_summary(cutoff_date='2024-05-31'):
    """Get a summary of missed follow-ups grouped by date."""
    try:
        database_url = get_database_url()
        engine = create_engine(database_url, connect_args={'sslmode': 'require'})
        
        # Query to get missed follow-ups summary grouped by date
        query = text("""
            SELECT 
                DATE(followup_date) as followup_date,
                COUNT(*) as total_count,
                COUNT(CASE WHEN status = 'Needs Followup' THEN 1 END) as needs_followup,
                COUNT(CASE WHEN status = 'Did Not Pick Up' THEN 1 END) as did_not_pickup,
                COUNT(CASE WHEN status = 'Open' THEN 1 END) as open_status,
                u.name as created_by
            FROM lead l
            JOIN "user" u ON l.creator_id = u.id
            WHERE 
                DATE(followup_date) < :cutoff_date
                AND l.status IN ('Needs Followup', 'Open', 'Did Not Pick Up')
            GROUP BY 
                DATE(followup_date), u.name
            ORDER BY 
                DATE(followup_date) ASC, u.name ASC
        """)
        
        with engine.connect() as connection:
            result = connection.execute(query, {'cutoff_date': cutoff_date})
            rows = result.fetchall()
        
        # Group by date
        date_summary = defaultdict(lambda: {
            'total': 0, 
            'needs_followup': 0, 
            'did_not_pickup': 0, 
            'open': 0,
            'by_user': {}
        })
        
        for row in rows:
            followup_date = row[0]
            total_count = row[1]
            needs_followup = row[2]
            did_not_pickup = row[3]
            open_status = row[4]
            created_by = row[5]
            
            date_summary[followup_date]['total'] += total_count
            date_summary[followup_date]['needs_followup'] += needs_followup
            date_summary[followup_date]['did_not_pickup'] += did_not_pickup
            date_summary[followup_date]['open'] += open_status
            date_summary[followup_date]['by_user'][created_by] = {
                'total': total_count,
                'needs_followup': needs_followup,
                'did_not_pickup': did_not_pickup,
                'open': open_status
            }
        
        return dict(date_summary)
        
    except Exception as e:
        print(f"Error fetching summary: {e}")
        return {}

def print_summary(summary_data, cutoff_date='2024-05-31'):
    """Print a concise summary report."""
    
    print(f"\n{'='*80}")
    print(f"MISSED FOLLOW-UPS SUMMARY REPORT")
    print(f"All pending follow-ups before {cutoff_date}")
    print(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*80}")
    
    if not summary_data:
        print("\n✅ No missed follow-ups found!")
        return
    
    # Calculate totals
    total_missed = sum(data['total'] for data in summary_data.values())
    total_needs_followup = sum(data['needs_followup'] for data in summary_data.values())
    total_did_not_pickup = sum(data['did_not_pickup'] for data in summary_data.values())
    total_open = sum(data['open'] for data in summary_data.values())
    
    print(f"\n📊 OVERALL SUMMARY:")
    print(f"   Total missed follow-ups: {total_missed}")
    print(f"   • Needs Followup: {total_needs_followup}")
    print(f"   • Did Not Pick Up: {total_did_not_pickup}")
    print(f"   • Open: {total_open}")
    print(f"   Number of dates affected: {len(summary_data)}")
    
    # Sort dates
    sorted_dates = sorted(summary_data.keys())
    
    print(f"\n📅 BY DATE BREAKDOWN:")
    print("-" * 80)
    
    for followup_date in sorted_dates:
        data = summary_data[followup_date]
        print(f"\n📅 {followup_date} - Total: {data['total']} follow-ups")
        print(f"    • Needs Followup: {data['needs_followup']}")
        print(f"    • Did Not Pick Up: {data['did_not_pickup']}")
        print(f"    • Open: {data['open']}")
        
        # Show breakdown by user
        print(f"    👥 By team member:")
        for user, user_data in data['by_user'].items():
            print(f"       {user}: {user_data['total']} total "
                  f"(Followup: {user_data['needs_followup']}, "
                  f"No pickup: {user_data['did_not_pickup']}, "
                  f"Open: {user_data['open']})")

def main():
    """Main function."""
    cutoff_date = '2024-05-31'
    
    print(f"Fetching missed follow-ups summary before {cutoff_date}...")
    
    try:
        summary = get_missed_followups_summary(cutoff_date)
        print_summary(summary, cutoff_date)
        
        # If no results for the specified date, try with today's date
        if not summary:
            today = datetime.now().date()
            recent_cutoff = today.strftime('%Y-%m-%d')
            print(f"\n🔍 No results for {cutoff_date}. Trying with {recent_cutoff}...")
            
            recent_summary = get_missed_followups_summary(recent_cutoff)
            if recent_summary:
                print_summary(recent_summary, recent_cutoff)
            else:
                print(f"No missed follow-ups found before {recent_cutoff} either.")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main() 