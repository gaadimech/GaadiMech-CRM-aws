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

def get_user_ids():
    """Get user IDs for Anil and Shivam"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Get Anil's user ID
        cur.execute("SELECT id FROM \"user\" WHERE name = 'Anil'")
        anil_id = cur.fetchone()
        
        # Get Shivam's user ID
        cur.execute("SELECT id FROM \"user\" WHERE name = 'Shivam'")
        shivam_id = cur.fetchone()
        
        cur.close()
        conn.close()
        
        if not anil_id:
            raise Exception("Anil not found in database")
        if not shivam_id:
            raise Exception("Shivam not found in database")
            
        return anil_id[0], shivam_id[0]
        
    except Exception as e:
        print(f"❌ Error getting user IDs: {e}")
        return None, None

def get_missed_leads(user_id, user_name):
    """Get all missed leads for a user (followup date before August 24th, 2025)"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Set target date (August 24th, 2025)
        target_date = datetime(2025, 8, 24)
        ist = pytz.timezone('Asia/Kolkata')
        target_date_ist = ist.localize(target_date)
        
        # Get all missed leads for the user
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
        """, (user_id, target_date_ist))
        
        leads = cur.fetchall()
        cur.close()
        conn.close()
        
        return leads
        
    except Exception as e:
        print(f"❌ Error getting {user_name}'s missed leads: {e}")
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

def update_missed_leads_future_dates(user_id, user_name, leads, start_date, leads_per_day):
    """Update missed leads to have future followup dates"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Calculate new followup dates
        followup_dates = calculate_new_followup_dates(len(leads), start_date, leads_per_day)
        
        # Start transaction
        conn.autocommit = False
        
        updated_count = 0
        errors = []
        
        print(f"🔄 Starting update of {len(leads)} missed leads for {user_name}...")
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
                
                # Print progress every 100 leads
                if (i + 1) % 100 == 0:
                    print(f"✅ Updated {i + 1}/{len(leads)} leads for {user_name}...")
                
            except Exception as e:
                errors.append(f"Lead ID {lead_id}: {str(e)}")
                print(f"❌ Error updating lead {lead_id}: {e}")
        
        # Commit transaction
        conn.commit()
        cur.close()
        conn.close()
        
        print("-" * 60)
        print(f"✅ Update completed for {user_name}!")
        print(f"📊 Successfully updated: {updated_count} leads")
        print(f"❌ Errors: {len(errors)}")
        
        if errors:
            print(f"\n🚨 Errors encountered for {user_name}:")
            for error in errors[:10]:  # Show first 10 errors
                print(f"  - {error}")
            if len(errors) > 10:
                print(f"  ... and {len(errors) - 10} more errors")
        
        return updated_count, errors
        
    except Exception as e:
        print(f"❌ Error in update process for {user_name}: {e}")
        if 'conn' in locals():
            conn.rollback()
            conn.close()
        return 0, [str(e)]

def create_update_summary(user_name, leads, start_date, updated_count, leads_per_day):
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
    
    print(f"\n📋 Update Summary for {user_name}:")
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
    print("🔄 Starting Missed Leads Future Date Update Process")
    print("=" * 60)
    
    # Get user IDs
    anil_id, shivam_id = get_user_ids()
    if not anil_id or not shivam_id:
        print("❌ Failed to get user IDs")
        return
    
    print(f"✅ Found Anil (ID: {anil_id}) and Shivam (ID: {shivam_id})")
    
    # Set start date (August 25th, 2025)
    start_date = datetime(2025, 8, 25)
    ist = pytz.timezone('Asia/Kolkata')
    start_date_ist = ist.localize(start_date)
    
    # Process Anil's missed leads
    print(f"\n{'='*20} PROCESSING ANIL {'='*20}")
    anil_leads = get_missed_leads(anil_id, "Anil")
    if anil_leads:
        print(f"📊 Found {len(anil_leads)} missed leads for Anil")
        
        # Calculate leads per day for Anil (considering his current workload)
        anil_leads_per_day = 50  # Conservative approach
        
        # Update Anil's missed leads
        anil_updated, anil_errors = update_missed_leads_future_dates(
            anil_id, "Anil", anil_leads, start_date_ist, anil_leads_per_day
        )
        
        # Create summary for Anil
        create_update_summary("Anil", anil_leads, start_date_ist, anil_updated, anil_leads_per_day)
    else:
        print("✅ No missed leads found for Anil")
    
    # Process Shivam's missed leads
    print(f"\n{'='*20} PROCESSING SHIVAM {'='*20}")
    shivam_leads = get_missed_leads(shivam_id, "Shivam")
    if shivam_leads:
        print(f"📊 Found {len(shivam_leads)} missed leads for Shivam")
        
        # Calculate leads per day for Shivam
        shivam_leads_per_day = 30  # Conservative approach for Shivam
        
        # Update Shivam's missed leads
        shivam_updated, shivam_errors = update_missed_leads_future_dates(
            shivam_id, "Shivam", shivam_leads, start_date_ist, shivam_leads_per_day
        )
        
        # Create summary for Shivam
        create_update_summary("Shivam", shivam_leads, start_date_ist, shivam_updated, shivam_leads_per_day)
    else:
        print("✅ No missed leads found for Shivam")
    
    # Final summary
    total_anil = len(anil_leads) if anil_leads else 0
    total_shivam = len(shivam_leads) if shivam_leads else 0
    total_updated = (anil_updated if 'anil_updated' in locals() else 0) + (shivam_updated if 'shivam_updated' in locals() else 0)
    
    print(f"\n{'='*60}")
    print(f"🎯 FINAL SUMMARY")
    print(f"{'='*60}")
    print(f"📊 Total missed leads found: {total_anil + total_shivam}")
    print(f"✅ Total leads updated: {total_updated}")
    print(f"👤 Anil: {total_anil} leads → {anil_updated if 'anil_updated' in locals() else 0} updated")
    print(f"👤 Shivam: {total_shivam} leads → {shivam_updated if 'shivam_updated' in locals() else 0} updated")
    print(f"📅 All leads now have future followup dates starting from: {start_date_ist.strftime('%Y-%m-%d')}")
    
    print(f"\n✅ Missed leads update process completed!")

if __name__ == "__main__":
    main()
