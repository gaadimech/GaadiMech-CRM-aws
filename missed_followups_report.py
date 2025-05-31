#!/usr/bin/env python3
"""
Missed Follow-ups Report Generator

This script queries the CRM database to find all pending follow-ups 
that have been missed (before a specified date), grouped by date.
"""

import os
from datetime import datetime, date
from collections import defaultdict
from sqlalchemy import create_engine, text

def get_database_url():
    """Get the database URL using the same logic as the main Flask app."""
    # Get DATABASE_URL from environment variable (AWS RDS connection string)
    DATABASE_URL = os.getenv("DATABASE_URL")

    # AWS RDS fallback configuration
    if not DATABASE_URL:
        # Replace these with your actual AWS RDS credentials
        RDS_HOST = os.getenv("RDS_HOST", "gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
        RDS_DB = os.getenv("RDS_DB", "crmportal")
        RDS_USER = os.getenv("RDS_USER", "postgres")
        RDS_PASSWORD = os.getenv("RDS_PASSWORD", "GaadiMech2024!")
        RDS_PORT = os.getenv("RDS_PORT", "5432")
        
        DATABASE_URL = f"postgresql://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"

    # Ensure we're using postgresql:// format (not postgres://)
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    
    return DATABASE_URL

def get_missed_followups(cutoff_date=None):
    """
    Get missed follow-ups before the specified cutoff date.
    
    Args:
        cutoff_date (str): Date in YYYY-MM-DD format. Defaults to '2024-05-31'
    
    Returns:
        dict: Dictionary with dates as keys and list of missed follow-ups as values
    """
    if cutoff_date is None:
        cutoff_date = '2024-05-31'
    
    try:
        # Create database connection
        database_url = get_database_url()
        engine = create_engine(database_url, connect_args={'sslmode': 'require'})
        
        # Query to get missed follow-ups
        query = text("""
            SELECT 
                DATE(followup_date) as followup_date,
                l.id,
                l.customer_name,
                l.mobile,
                l.car_registration,
                l.followup_date,
                l.remarks,
                l.status,
                l.created_at,
                u.name as created_by
            FROM lead l
            JOIN "user" u ON l.creator_id = u.id
            WHERE 
                DATE(followup_date) < :cutoff_date
                AND l.status IN ('Needs Followup', 'Open', 'Did Not Pick Up')
            ORDER BY 
                DATE(followup_date) ASC,
                l.followup_date ASC
        """)
        
        with engine.connect() as connection:
            result = connection.execute(query, {'cutoff_date': cutoff_date})
            rows = result.fetchall()
        
        # Group results by date
        grouped_followups = defaultdict(list)
        
        for row in rows:
            followup_date = row[0]  # This is the DATE(followup_date)
            followup_info = {
                'id': row[1],
                'customer_name': row[2],
                'mobile': row[3],
                'car_registration': row[4],
                'followup_datetime': row[5],  # Full datetime
                'remarks': row[6],
                'status': row[7],
                'created_at': row[8],
                'created_by': row[9]
            }
            grouped_followups[followup_date].append(followup_info)
        
        return dict(grouped_followups)
        
    except Exception as e:
        print(f"Error fetching missed follow-ups: {e}")
        return {}

def get_database_stats():
    """Get basic statistics about the database contents."""
    try:
        # Create database connection
        database_url = get_database_url()
        engine = create_engine(database_url, connect_args={'sslmode': 'require'})
        
        with engine.connect() as connection:
            # Get total leads count
            total_leads_result = connection.execute(text("SELECT COUNT(*) FROM lead"))
            total_leads = total_leads_result.fetchone()[0]
            
            # Get leads by status
            status_result = connection.execute(text("""
                SELECT status, COUNT(*) as count 
                FROM lead 
                GROUP BY status 
                ORDER BY count DESC
            """))
            status_counts = status_result.fetchall()
            
            # Get date range of follow-ups
            date_range_result = connection.execute(text("""
                SELECT 
                    MIN(DATE(followup_date)) as earliest_followup,
                    MAX(DATE(followup_date)) as latest_followup
                FROM lead
            """))
            date_range = date_range_result.fetchone()
            
            # Get recent follow-ups (last 30 days)
            recent_result = connection.execute(text("""
                SELECT COUNT(*) 
                FROM lead 
                WHERE followup_date >= CURRENT_DATE - INTERVAL '30 days'
            """))
            recent_followups = recent_result.fetchone()[0]
            
            return {
                'total_leads': total_leads,
                'status_counts': status_counts,
                'earliest_followup': date_range[0],
                'latest_followup': date_range[1],
                'recent_followups': recent_followups
            }
            
    except Exception as e:
        print(f"Error fetching database stats: {e}")
        return None

def print_report(missed_followups, cutoff_date='2024-05-31'):
    """Print a formatted report of missed follow-ups."""
    
    print(f"\n{'='*80}")
    print(f"MISSED FOLLOW-UPS REPORT")
    print(f"All pending follow-ups before {cutoff_date}")
    print(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*80}")
    
    if not missed_followups:
        print("\n✅ No missed follow-ups found!")
        return
    
    total_missed = sum(len(followups) for followups in missed_followups.values())
    print(f"\nTotal missed follow-ups: {total_missed}")
    print(f"Number of dates with missed follow-ups: {len(missed_followups)}")
    
    # Sort dates
    sorted_dates = sorted(missed_followups.keys())
    
    for followup_date in sorted_dates:
        followups = missed_followups[followup_date]
        print(f"\n📅 {followup_date} ({len(followups)} follow-ups)")
        print("-" * 60)
        
        for i, followup in enumerate(followups, 1):
            print(f"  {i}. {followup['customer_name']}")
            print(f"     📱 Mobile: {followup['mobile']}")
            if followup['car_registration']:
                print(f"     🚗 Car: {followup['car_registration']}")
            print(f"     🕐 Time: {followup['followup_datetime']}")
            print(f"     📊 Status: {followup['status']}")
            print(f"     👤 Created by: {followup['created_by']}")
            if followup['remarks']:
                print(f"     📝 Remarks: {followup['remarks'][:100]}{'...' if len(followup['remarks']) > 100 else ''}")
            print()

def export_to_csv(missed_followups, filename=None):
    """Export missed follow-ups to CSV file."""
    import csv
    
    if filename is None:
        filename = f"missed_followups_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
    
    try:
        with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
            fieldnames = [
                'followup_date', 'customer_name', 'mobile', 'car_registration', 
                'followup_datetime', 'status', 'created_by', 'remarks'
            ]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            
            writer.writeheader()
            
            # Sort dates
            sorted_dates = sorted(missed_followups.keys())
            
            for followup_date in sorted_dates:
                for followup in missed_followups[followup_date]:
                    writer.writerow({
                        'followup_date': followup_date,
                        'customer_name': followup['customer_name'],
                        'mobile': followup['mobile'],
                        'car_registration': followup['car_registration'] or '',
                        'followup_datetime': followup['followup_datetime'],
                        'status': followup['status'],
                        'created_by': followup['created_by'],
                        'remarks': followup['remarks'] or ''
                    })
        
        print(f"\n✅ Report exported to: {filename}")
        return filename
        
    except Exception as e:
        print(f"❌ Error exporting to CSV: {e}")
        return None

def main():
    """Main function to run the missed follow-ups report."""
    
    print("Fetching database statistics...")
    
    # Get database stats first
    stats = get_database_stats()
    if stats:
        print(f"\n📊 Database Statistics:")
        print(f"   Total leads: {stats['total_leads']}")
        print(f"   Follow-up date range: {stats['earliest_followup']} to {stats['latest_followup']}")
        print(f"   Recent follow-ups (last 30 days): {stats['recent_followups']}")
        print(f"\n   Status breakdown:")
        for status, count in stats['status_counts']:
            print(f"     {status}: {count}")
    
    # You can change this date to any cutoff date you want
    cutoff_date = '2024-05-31'
    
    print(f"\nFetching missed follow-ups before {cutoff_date}...")
    
    try:
        missed_followups = get_missed_followups(cutoff_date)
        
        # Print console report
        print_report(missed_followups, cutoff_date)
        
        # If no results for May 31st, try a more recent date
        if not missed_followups and stats and stats['latest_followup']:
            print(f"\n🔍 No missed follow-ups found before {cutoff_date}.")
            print(f"Let's try a more recent cutoff date...")
            
            # Try with today's date
            today = datetime.now().date()
            recent_cutoff = today.strftime('%Y-%m-%d')
            print(f"\nTrying with cutoff date: {recent_cutoff}")
            
            recent_missed = get_missed_followups(recent_cutoff)
            if recent_missed:
                print_report(recent_missed, recent_cutoff)
                # Export to CSV
                csv_file = export_to_csv(recent_missed, f"missed_followups_before_{recent_cutoff.replace('-', '')}.csv")
            else:
                print(f"No missed follow-ups found before {recent_cutoff} either.")
        
        # Export to CSV if we have results
        elif missed_followups:
            csv_file = export_to_csv(missed_followups)
            print(f"\n📊 Summary:")
            print(f"   Total dates with missed follow-ups: {len(missed_followups)}")
            print(f"   Total missed follow-ups: {sum(len(followups) for followups in missed_followups.values())}")
            
            # Show date range
            if missed_followups:
                sorted_dates = sorted(missed_followups.keys())
                print(f"   Date range: {sorted_dates[0]} to {sorted_dates[-1]}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\nPlease ensure:")
        print("1. Your .env file contains the correct database credentials")
        print("2. You have network access to the AWS RDS database")
        print("3. The database tables exist and are accessible")

if __name__ == "__main__":
    main() 