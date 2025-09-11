#!/usr/bin/env python3
import os
import psycopg2
from datetime import datetime, timedelta
from dotenv import load_dotenv
import pytz

# Load environment variables
load_dotenv()

# Database connection parameters
DB_PARAMS = {
    'host': os.getenv('RDS_HOST', 'crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com'),
    'database': os.getenv('RDS_DB', 'crmportal'),
    'user': os.getenv('RDS_USER', 'crmadmin'),
    'password': os.getenv('RDS_PASSWORD', 'GaadiMech2024!'),
    'port': os.getenv('RDS_PORT', '5432')
}

def get_hemlata_id():
    """Get Hemlata's user ID"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Get Hemlata's user ID
        cur.execute("SELECT id FROM \"user\" WHERE name = 'Hemlata'")
        hemlata_id = cur.fetchone()
        
        cur.close()
        conn.close()
        
        if not hemlata_id:
            raise Exception("Hemlata not found in database")
            
        return hemlata_id[0]
        
    except Exception as e:
        print(f"❌ Error getting Hemlata's user ID: {e}")
        return None

def get_hemlata_missed_leads(hemlata_id):
    """Get all of Hemlata's leads with followup date before August 24th, 2025"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Set target date (August 24th, 2025)
        target_date = datetime(2025, 8, 24)
        ist = pytz.timezone('Asia/Kolkata')
        target_date_ist = ist.localize(target_date)
        
        # Get all of Hemlata's leads with followup date before August 24th
        cur.execute("""
            SELECT 
                id,
                customer_name,
                mobile,
                car_registration,
                followup_date,
                remarks,
                status,
                created_at,
                modified_at
            FROM lead 
            WHERE creator_id = %s AND followup_date < %s
            ORDER BY followup_date ASC
        """, (hemlata_id, target_date_ist))
        
        leads = cur.fetchall()
        cur.close()
        conn.close()
        
        return leads
        
    except Exception as e:
        print(f"❌ Error getting Hemlata's missed leads: {e}")
        return []

def calculate_new_followup_dates(leads_count, start_date, leads_per_day):
    """Calculate new followup dates: leads_per_day leads per day starting from start_date"""
    followup_dates = []
    current_date = start_date
    
    for i in range(leads_count):
        if i > 0 and i % leads_per_day == 0:
            current_date += timedelta(days=1)
        followup_dates.append(current_date)
    
    return followup_dates

def update_hemlata_missed_leads(hemlata_id, leads, start_date, leads_per_day):
    """Update Hemlata's missed leads to have future followup dates"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Calculate new followup dates
        followup_dates = calculate_new_followup_dates(len(leads), start_date, leads_per_day)
        
        # Start transaction
        conn.autocommit = False
        
        updated_count = 0
        errors = []
        
        print(f"🔄 Starting update of {len(leads)} missed leads for Hemlata...")
        print(f"📅 Starting from: {start_date.strftime('%Y-%m-%d')}")
        print(f"📊 {leads_per_day} leads per day will be assigned")
        print("-" * 60)
        
        for i, (lead_id, customer_name, mobile, car_registration, old_followup_date, remarks, status, created_at, modified_at) in enumerate(leads):
            try:
                new_followup_date = followup_dates[i]
                
                # Update the lead with new followup date
                cur.execute("""
                    UPDATE lead 
                    SET 
                        followup_date = %s,
                        modified_at = %s
                    WHERE id = %s
                """, (new_followup_date, datetime.now(pytz.timezone('Asia/Kolkata')), lead_id))
                
                updated_count += 1
                
                # Print progress every 50 leads
                if (i + 1) % 50 == 0:
                    print(f"✅ Updated {i + 1}/{len(leads)} leads for Hemlata...")
                
            except Exception as e:
                errors.append(f"Lead ID {lead_id}: {str(e)}")
                print(f"❌ Error updating lead {lead_id}: {e}")
        
        # Commit transaction
        conn.commit()
        cur.close()
        conn.close()
        
        print("-" * 60)
        print(f"✅ Update completed for Hemlata!")
        print(f"📊 Successfully updated: {updated_count} leads")
        print(f"❌ Errors: {len(errors)}")
        
        if errors:
            print(f"\n🚨 Errors encountered for Hemlata:")
            for error in errors[:10]:  # Show first 10 errors
                print(f"  - {error}")
            if len(errors) > 10:
                print(f"  ... and {len(errors) - 10} more errors")
        
        return updated_count, errors
        
    except Exception as e:
        print(f"❌ Error in update process for Hemlata: {e}")
        if 'conn' in locals():
            conn.rollback()
            conn.close()
        return 0, [str(e)]

def create_update_summary(leads, start_date, updated_count, leads_per_day):
    """Create a summary of the update"""
    if not leads:
        return
    
    # Calculate date ranges
    followup_dates = calculate_new_followup_dates(len(leads), start_date, leads_per_day)
    end_date = followup_dates[-1]
    
    # Count by status
    status_counts = {}
    for _, _, _, _, _, _, status, _, _ in leads:
        status_counts[status] = status_counts.get(status, 0) + 1
    
    print(f"\n📋 Update Summary for Hemlata:")
    print("=" * 50)
    print(f"📅 Start Date: {start_date.strftime('%Y-%m-%d')}")
    print(f"📅 End Date: {end_date.strftime('%Y-%m-%d')}")
    print(f"📊 Total Leads: {len(leads)}")
    print(f"✅ Updated: {updated_count}")
    print(f"📈 Distribution: {len(followup_dates)} days")
    print(f"📊 Daily Rate: {leads_per_day} leads per day")
    
    print(f"\n📈 Status Breakdown:")
    for status, count in sorted(status_counts.items()):
        print(f"  - {status}: {count}")
    
    print(f"\n📅 Daily Distribution:")
    current_date = start_date
    daily_count = 0
    for i, date in enumerate(followup_dates):
        if date.date() == current_date.date():
            daily_count += 1
        else:
            print(f"  - {current_date.strftime('%Y-%m-%d')}: {daily_count} leads")
            current_date = date
            daily_count = 1
    
    # Print last day
    if daily_count > 0:
        print(f"  - {current_date.strftime('%Y-%m-%d')}: {daily_count} leads")

def main():
    print("🔄 Starting Hemlata Missed Leads Future Date Update Process")
    print("=" * 60)
    
    # Get Hemlata's user ID
    hemlata_id = get_hemlata_id()
    if not hemlata_id:
        print("❌ Failed to get Hemlata's user ID")
        return
    
    print(f"✅ Found Hemlata (ID: {hemlata_id})")
    
    # Get Hemlata's missed leads
    leads = get_hemlata_missed_leads(hemlata_id)
    if not leads:
        print("❌ No missed leads found for Hemlata")
        return
    
    print(f"📊 Found {len(leads)} missed leads for Hemlata")
    
    # Set start date (August 26th, 2025)
    start_date = datetime(2025, 8, 26)
    ist = pytz.timezone('Asia/Kolkata')
    start_date_ist = ist.localize(start_date)
    
    # Set leads per day
    leads_per_day = 50
    
    # Confirm before proceeding
    print(f"\n⚠️  About to update {len(leads)} missed leads for Hemlata")
    print(f"📅 Starting from: {start_date_ist.strftime('%Y-%m-%d')}")
    print(f"📊 {leads_per_day} leads per day will be assigned")
    
    # Update the leads
    updated_count, errors = update_hemlata_missed_leads(hemlata_id, leads, start_date_ist, leads_per_day)
    
    # Create summary
    create_update_summary(leads, start_date_ist, updated_count, leads_per_day)
    
    print(f"\n✅ Lead update process completed!")
    print(f"📊 Successfully updated {updated_count} out of {len(leads)} leads")

if __name__ == "__main__":
    main()
