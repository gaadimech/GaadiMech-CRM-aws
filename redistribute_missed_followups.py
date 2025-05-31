#!/usr/bin/env python3
"""
Redistribute Missed Follow-ups

This script redistributes all missed follow-ups to Hemlata and Sneha
starting from June 1st, with 50 leads each per day.
"""

import os
from datetime import datetime, date, timedelta
from sqlalchemy import create_engine, text
from collections import defaultdict

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

def get_user_ids():
    """Get user IDs for Hemlata and Sneha."""
    try:
        database_url = get_database_url()
        engine = create_engine(database_url, connect_args={'sslmode': 'require'})
        
        with engine.connect() as connection:
            # Get user IDs
            user_query = text("""
                SELECT id, name, username 
                FROM "user" 
                WHERE LOWER(name) IN ('hemlata', 'sneha')
                ORDER BY name
            """)
            result = connection.execute(user_query)
            users = result.fetchall()
            
            user_mapping = {}
            for user in users:
                user_mapping[user[1].lower()] = {
                    'id': user[0],
                    'name': user[1],
                    'username': user[2]
                }
            
            return user_mapping
            
    except Exception as e:
        print(f"Error fetching user IDs: {e}")
        return {}

def get_missed_followups(cutoff_date='2024-05-31'):
    """Get all missed follow-ups that need to be redistributed."""
    try:
        database_url = get_database_url()
        engine = create_engine(database_url, connect_args={'sslmode': 'require'})
        
        # Query to get all missed follow-ups
        query = text("""
            SELECT 
                l.id,
                l.customer_name,
                l.mobile,
                l.car_registration,
                l.followup_date,
                l.remarks,
                l.status,
                l.created_at,
                l.creator_id,
                u.name as created_by
            FROM lead l
            JOIN "user" u ON l.creator_id = u.id
            WHERE 
                DATE(followup_date) < :cutoff_date
                AND l.status IN ('Needs Followup', 'Open', 'Did Not Pick Up')
            ORDER BY 
                l.followup_date ASC,
                l.id ASC
        """)
        
        with engine.connect() as connection:
            result = connection.execute(query, {'cutoff_date': cutoff_date})
            rows = result.fetchall()
        
        missed_leads = []
        for row in rows:
            missed_leads.append({
                'id': row[0],
                'customer_name': row[1],
                'mobile': row[2],
                'car_registration': row[3],
                'followup_date': row[4],
                'remarks': row[5],
                'status': row[6],
                'created_at': row[7],
                'creator_id': row[8],
                'created_by': row[9]
            })
        
        return missed_leads
        
    except Exception as e:
        print(f"Error fetching missed follow-ups: {e}")
        return []

def redistribute_followups(missed_leads, user_mapping, start_date='2025-06-01', leads_per_person_per_day=50):
    """
    Redistribute missed follow-ups to Hemlata and Sneha.
    
    Args:
        missed_leads: List of missed lead records
        user_mapping: Dictionary with user information
        start_date: Start date for redistribution (YYYY-MM-DD)
        leads_per_person_per_day: Number of leads per person per day
    """
    
    if 'hemlata' not in user_mapping or 'sneha' not in user_mapping:
        print("❌ Error: Could not find Hemlata or Sneha in user mapping")
        print("Available users:", list(user_mapping.keys()))
        return False
    
    hemlata_id = user_mapping['hemlata']['id']
    sneha_id = user_mapping['sneha']['id']
    
    print(f"📋 Redistributing {len(missed_leads)} leads...")
    print(f"   Hemlata ID: {hemlata_id}")
    print(f"   Sneha ID: {sneha_id}")
    print(f"   Start date: {start_date}")
    print(f"   Leads per person per day: {leads_per_person_per_day}")
    
    # Calculate redistribution plan
    redistribution_plan = []
    current_date = datetime.strptime(start_date, '%Y-%m-%d').date()
    
    lead_index = 0
    total_leads = len(missed_leads)
    
    while lead_index < total_leads:
        # Assign leads for current date
        daily_assignments = []
        
        # Assign to Hemlata
        for i in range(leads_per_person_per_day):
            if lead_index < total_leads:
                lead = missed_leads[lead_index]
                daily_assignments.append({
                    'lead_id': lead['id'],
                    'customer_name': lead['customer_name'],
                    'mobile': lead['mobile'],
                    'new_followup_date': current_date,
                    'new_assignee_id': hemlata_id,
                    'new_assignee_name': 'Hemlata',
                    'original_date': lead['followup_date'],
                    'original_assignee': lead['created_by']
                })
                lead_index += 1
        
        # Assign to Sneha
        for i in range(leads_per_person_per_day):
            if lead_index < total_leads:
                lead = missed_leads[lead_index]
                daily_assignments.append({
                    'lead_id': lead['id'],
                    'customer_name': lead['customer_name'],
                    'mobile': lead['mobile'],
                    'new_followup_date': current_date,
                    'new_assignee_id': sneha_id,
                    'new_assignee_name': 'Sneha',
                    'original_date': lead['followup_date'],
                    'original_assignee': lead['created_by']
                })
                lead_index += 1
        
        if daily_assignments:
            redistribution_plan.append({
                'date': current_date,
                'assignments': daily_assignments
            })
        
        # Move to next day
        current_date += timedelta(days=1)
    
    return redistribution_plan

def apply_redistribution(redistribution_plan, dry_run=True):
    """Apply the redistribution plan to the database."""
    
    if dry_run:
        print("\n🔍 DRY RUN MODE - No changes will be made to the database")
        print("=" * 80)
    else:
        print("\n💾 APPLYING CHANGES TO DATABASE")
        print("=" * 80)
    
    total_updates = 0
    
    for day_plan in redistribution_plan:
        date_str = day_plan['date'].strftime('%Y-%m-%d')
        assignments = day_plan['assignments']
        
        hemlata_count = sum(1 for a in assignments if a['new_assignee_name'] == 'Hemlata')
        sneha_count = sum(1 for a in assignments if a['new_assignee_name'] == 'Sneha')
        
        print(f"\n📅 {date_str}: {len(assignments)} leads")
        print(f"   Hemlata: {hemlata_count} leads")
        print(f"   Sneha: {sneha_count} leads")
        
        if not dry_run:
            # Apply database updates
            try:
                database_url = get_database_url()
                engine = create_engine(database_url, connect_args={'sslmode': 'require'})
                
                with engine.connect() as connection:
                    # Begin transaction
                    trans = connection.begin()
                    
                    try:
                        for assignment in assignments:
                            # Update follow-up date and assignee
                            # Set followup_date to 10:00 AM on the assigned date
                            new_datetime = datetime.combine(assignment['new_followup_date'], datetime.min.time().replace(hour=10))
                            
                            update_query = text("""
                                UPDATE lead 
                                SET 
                                    followup_date = :new_followup_date,
                                    creator_id = :new_assignee_id,
                                    modified_at = CURRENT_TIMESTAMP,
                                    status = 'Needs Followup'
                                WHERE id = :lead_id
                            """)
                            
                            connection.execute(update_query, {
                                'new_followup_date': new_datetime,
                                'new_assignee_id': assignment['new_assignee_id'],
                                'lead_id': assignment['lead_id']
                            })
                            
                            total_updates += 1
                        
                        # Commit transaction
                        trans.commit()
                        print(f"   ✅ Successfully updated {len(assignments)} leads")
                        
                    except Exception as e:
                        trans.rollback()
                        print(f"   ❌ Error updating leads for {date_str}: {e}")
                        break
                        
            except Exception as e:
                print(f"   ❌ Database connection error: {e}")
                break
        
        # Show some sample assignments
        if len(assignments) > 0:
            print(f"   📋 Sample assignments:")
            for i, assignment in enumerate(assignments[:3]):  # Show first 3
                print(f"      {i+1}. {assignment['customer_name']} ({assignment['mobile']}) -> {assignment['new_assignee_name']}")
            if len(assignments) > 3:
                print(f"      ... and {len(assignments) - 3} more")
    
    print(f"\n📊 SUMMARY:")
    print(f"   Total leads processed: {total_updates}")
    print(f"   Number of days: {len(redistribution_plan)}")
    if redistribution_plan:
        start_date = redistribution_plan[0]['date']
        end_date = redistribution_plan[-1]['date']
        print(f"   Date range: {start_date} to {end_date}")
    
    return total_updates

def main():
    """Main function to redistribute missed follow-ups."""
    
    print("🔄 MISSED FOLLOW-UPS REDISTRIBUTION")
    print("=" * 80)
    
    # Step 1: Get user IDs
    print("1️⃣ Fetching user information...")
    user_mapping = get_user_ids()
    
    if not user_mapping:
        print("❌ Could not fetch user information")
        return
    
    print("✅ Found users:")
    for name, info in user_mapping.items():
        print(f"   {info['name']} (ID: {info['id']}, Username: {info['username']})")
    
    # Step 2: Get missed follow-ups - Updated cutoff date to 2025
    print("\n2️⃣ Fetching missed follow-ups...")
    missed_leads = get_missed_followups('2025-05-31')  # Changed from 2024 to 2025
    
    if not missed_leads:
        print("❌ No missed follow-ups found")
        # Let's try with today's date as cutoff
        today = datetime.now().date().strftime('%Y-%m-%d')
        print(f"🔍 Trying with today's date as cutoff: {today}")
        missed_leads = get_missed_followups(today)
        
        if not missed_leads:
            print("❌ Still no missed follow-ups found")
            return
    
    print(f"✅ Found {len(missed_leads)} missed follow-ups")
    
    # Show some statistics about the missed leads
    if missed_leads:
        earliest_date = min(lead['followup_date'] for lead in missed_leads)
        latest_date = max(lead['followup_date'] for lead in missed_leads)
        print(f"   📅 Date range: {earliest_date.date()} to {latest_date.date()}")
        
        # Count by status
        status_counts = {}
        for lead in missed_leads:
            status = lead['status']
            status_counts[status] = status_counts.get(status, 0) + 1
        
        print(f"   📊 Status breakdown:")
        for status, count in status_counts.items():
            print(f"      {status}: {count}")
    
    # Step 3: Create redistribution plan
    print("\n3️⃣ Creating redistribution plan...")
    redistribution_plan = redistribute_followups(
        missed_leads, 
        user_mapping, 
        start_date='2025-06-01',
        leads_per_person_per_day=50
    )
    
    if not redistribution_plan:
        print("❌ Could not create redistribution plan")
        return
    
    print(f"✅ Created plan for {len(redistribution_plan)} days")
    
    # Step 4: Show dry run first
    print("\n4️⃣ Showing redistribution plan (Dry Run)...")
    apply_redistribution(redistribution_plan, dry_run=True)
    
    # Step 5: Ask for confirmation
    print("\n" + "="*80)
    confirmation = input("🤔 Do you want to apply these changes to the database? (yes/no): ").lower().strip()
    
    if confirmation == 'yes':
        print("\n5️⃣ Applying changes to database...")
        total_updated = apply_redistribution(redistribution_plan, dry_run=False)
        
        if total_updated > 0:
            print(f"\n🎉 SUCCESS! Redistributed {total_updated} leads")
            print("📈 All missed follow-ups have been reassigned to future dates")
        else:
            print("\n❌ No changes were made")
    else:
        print("\n🚫 Operation cancelled. No changes made to database.")

if __name__ == "__main__":
    main() 