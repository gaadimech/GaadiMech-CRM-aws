import csv
from datetime import datetime, timedelta
import pytz
from application import db, User, Lead, application

# Initialize timezone
ist = pytz.timezone('Asia/Kolkata')

def distribute_leads(leads, days=10):
    """Distribute leads evenly across the specified number of days"""
    leads_per_day = len(leads) // days
    remainder = len(leads) % days
    distribution = []
    
    start = 0
    for day in range(days):
        count = leads_per_day + (1 if day < remainder else 0)
        end = start + count
        distribution.append(leads[start:end])
        start = end
    
    return distribution

def main():
    with application.app_context():
        # Get Sneha's user ID
        sneha = User.query.filter_by(username='sneha').first()
        if not sneha:
            print("Error: User 'sneha' not found in database")
            return

        # Read mobile numbers from CSV
        leads = []
        with open('June 2025 Leads.csv', 'r') as file:
            reader = csv.DictReader(file)
            leads = [row['Mobile Number'] for row in reader]

        # Get current date in IST
        current_date = datetime.now(ist).date()
        
        # Distribute leads across 10 days
        distributed_leads = distribute_leads(leads, 10)
        
        # Insert leads into database
        for day_index, day_leads in enumerate(distributed_leads):
            followup_date = datetime.combine(
                current_date + timedelta(days=day_index),
                datetime.strptime('10:00', '%H:%M').time()
            )
            followup_date = ist.localize(followup_date)
            
            for mobile in day_leads:
                lead = Lead(
                    customer_name=f"June Lead - {mobile}",
                    mobile=mobile,
                    followup_date=followup_date,
                    remarks="Important June Lead",
                    status="Needs Followup",
                    creator_id=sneha.id
                )
                db.session.add(lead)
            
            try:
                db.session.commit()
                print(f"Added {len(day_leads)} leads for day {day_index + 1}")
            except Exception as e:
                db.session.rollback()
                print(f"Error on day {day_index + 1}: {str(e)}")

if __name__ == '__main__':
    main() 