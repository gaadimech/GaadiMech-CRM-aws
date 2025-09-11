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
    """Get user IDs for Sneha and Anil"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Get Sneha's user ID
        cur.execute("SELECT id FROM \"user\" WHERE name = 'Sneha'")
        sneha_id = cur.fetchone()
        
        # Get Anil's user ID
        cur.execute("SELECT id FROM \"user\" WHERE name = 'Anil'")
        anil_id = cur.fetchone()
        
        cur.close()
        conn.close()
        
        if not sneha_id:
            raise Exception("Sneha not found in database")
        if not anil_id:
            raise Exception("Anil not found in database")
            
        return sneha_id[0], anil_id[0]
        
    except Exception as e:
        print(f"❌ Error getting user IDs: {e}")
        return None, None

def get_sneha_remaining_leads(sneha_id):
    """Get all of Sneha's remaining leads (with followup date >= August 24th, 2025)"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Set target date (August 24th, 2025)
        target_date = datetime(2025, 8, 24)
        ist = pytz.timezone('Asia/Kolkata')
        target_date_ist = ist.localize(target_date)
        
        # Get all of Sneha's leads with followup date >= August 24th
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
            WHERE creator_id = %s AND followup_date >= %s
            ORDER BY followup_date ASC
        """, (sneha_id, target_date_ist))
        
        leads = cur.fetchall()
        cur.close()
        conn.close()
        
        return leads
        
    except Exception as e:
        print(f"❌ Error getting Sneha's remaining leads: {e}")
        return []

def calculate_new_followup_dates(leads_count, start_date):
    """Calculate new followup dates: 50 leads per day starting from start_date"""
    followup_dates = []
    current_date = start_date
    
    for i in range(leads_count):
        if i > 0 and i % 50 == 0:
            current_date += timedelta(days=1)
        followup_dates.append(current_date)
    
    return followup_dates

def transfer_leads_to_anil(sneha_id, anil_id, leads, start_date):
    """Transfer leads from Sneha to Anil with new followup dates"""
    try:
        conn = psycopg2.connect(**DB_PARAMS)
        cur = conn.cursor()
        
        # Calculate new followup dates
        followup_dates = calculate_new_followup_dates(len(leads), start_date)
        
        # Start transaction
        conn.autocommit = False
        
        transferred_count = 0
        errors = []
        
        print(f"🔄 Starting transfer of {len(leads)} leads from Sneha to Anil...")
        print(f"📅 Starting from: {start_date.strftime('%Y-%m-%d')}")
        print(f"📊 50 leads per day will be assigned")
        print("-" * 60)
        
        for i, (lead_id, customer_name, mobile, car_registration, old_followup_date, remarks, status, created_at, modified_at) in enumerate(leads):
            try:
                new_followup_date = followup_dates[i]
                
                # Update the lead
                cur.execute("""
                    UPDATE lead 
                    SET 
                        creator_id = %s,
                        followup_date = %s,
                        modified_at = %s
                    WHERE id = %s
                """, (anil_id, new_followup_date, datetime.now(pytz.timezone('Asia/Kolkata')), lead_id))
                
                transferred_count += 1
                
                # Print progress every 50 leads
                if (i + 1) % 50 == 0:
                    print(f"✅ Transferred {i + 1}/{len(leads)} leads...")
                
            except Exception as e:
                errors.append(f"Lead ID {lead_id}: {str(e)}")
                print(f"❌ Error transferring lead {lead_id}: {e}")
        
        # Commit transaction
        conn.commit()
        cur.close()
        conn.close()
        
        print("-" * 60)
        print(f"✅ Transfer completed!")
        print(f"📊 Successfully transferred: {transferred_count} leads")
        print(f"❌ Errors: {len(errors)}")
        
        if errors:
            print("\n🚨 Errors encountered:")
            for error in errors[:10]:  # Show first 10 errors
                print(f"  - {error}")
            if len(errors) > 10:
                print(f"  ... and {len(errors) - 10} more errors")
        
        return transferred_count, errors
        
    except Exception as e:
        print(f"❌ Error in transfer process: {e}")
        if 'conn' in locals():
            conn.rollback()
            conn.close()
        return 0, [str(e)]

def create_transfer_summary(leads, start_date, transferred_count):
    """Create a summary of the transfer"""
    if not leads:
        return
    
    # Calculate date ranges
    followup_dates = calculate_new_followup_dates(len(leads), start_date)
    end_date = followup_dates[-1]
    
    # Count by status
    status_counts = {}
    for _, _, _, _, _, _, status, _, _ in leads:
        status_counts[status] = status_counts.get(status, 0) + 1
    
    print("\n📋 Transfer Summary:")
    print("=" * 50)
    print(f"👤 From: Sneha")
    print(f"👤 To: Anil")
    print(f"📅 Start Date: {start_date.strftime('%Y-%m-%d')}")
    print(f"📅 End Date: {end_date.strftime('%Y-%m-%d')}")
    print(f"📊 Total Leads: {len(leads)}")
    print(f"✅ Transferred: {transferred_count}")
    print(f"📈 Distribution: {len(followup_dates)} days")
    
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
    print("🔄 Starting Sneha to Anil Remaining Lead Transfer Process")
    print("=" * 60)
    
    # Get user IDs
    sneha_id, anil_id = get_user_ids()
    if not sneha_id or not anil_id:
        print("❌ Failed to get user IDs")
        return
    
    print(f"✅ Found Sneha (ID: {sneha_id}) and Anil (ID: {anil_id})")
    
    # Get Sneha's remaining leads
    leads = get_sneha_remaining_leads(sneha_id)
    if not leads:
        print("❌ No remaining leads found for transfer")
        return
    
    print(f"📊 Found {len(leads)} remaining leads to transfer")
    
    # Set start date (August 25th, 2025)
    start_date = datetime(2025, 8, 25)
    ist = pytz.timezone('Asia/Kolkata')
    start_date_ist = ist.localize(start_date)
    
    # Confirm before proceeding
    print(f"\n⚠️  About to transfer {len(leads)} remaining leads from Sneha to Anil")
    print(f"📅 Starting from: {start_date_ist.strftime('%Y-%m-%d')}")
    print(f"📊 50 leads per day will be assigned")
    
    # Transfer the leads
    transferred_count, errors = transfer_leads_to_anil(sneha_id, anil_id, leads, start_date_ist)
    
    # Create summary
    create_transfer_summary(leads, start_date_ist, transferred_count)
    
    print(f"\n✅ Lead transfer process completed!")
    print(f"📊 Successfully transferred {transferred_count} out of {len(leads)} leads")

if __name__ == "__main__":
    main()
