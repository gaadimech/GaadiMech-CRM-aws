#!/usr/bin/env python3
"""
Script to fix the daily_followup_count table schema
"""

import os
import sys

# Set environment variables
os.environ['DATABASE_URL'] = 'postgresql://crmadmin:GaadiMech2024!@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal'
os.environ['SECRET_KEY'] = 'GaadiMech2024!'

def fix_daily_table():
    """Fix the daily_followup_count table schema"""
    try:
        from application import application, db
        
        with application.app_context():
            print("🔧 Fixing daily_followup_count table schema...")
            print("=" * 50)
            
            # Check current table structure
            result = db.session.execute(db.text("""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'daily_followup_count'
                ORDER BY ordinal_position;
            """)).fetchall()
            
            print("Current table structure:")
            for row in result:
                print(f"  - {row[0]}: {row[1]} (nullable: {row[2]}, default: {row[3]})")
            
            # Check if ID column has proper sequence
            seq_result = db.session.execute(db.text("""
                SELECT pg_get_serial_sequence('daily_followup_count', 'id');
            """)).fetchone()
            
            print(f"\nID sequence: {seq_result[0] if seq_result else 'None'}")
            
            if not seq_result or not seq_result[0]:
                print("\n🔧 Creating sequence for ID column...")
                
                # Drop and recreate the table with proper schema
                db.session.execute(db.text("DROP TABLE IF EXISTS daily_followup_count CASCADE;"))
                
                # Recreate table with proper structure
                db.session.execute(db.text("""
                    CREATE TABLE daily_followup_count (
                        id SERIAL PRIMARY KEY,
                        date DATE NOT NULL,
                        user_id INTEGER NOT NULL REFERENCES "user"(id),
                        initial_count INTEGER DEFAULT 0,
                        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                        UNIQUE(date, user_id)
                    );
                """))
                
                db.session.commit()
                print("✅ Table recreated with proper schema!")
            else:
                print("✅ Table schema is correct!")
            
            print("\nTesting insert...")
            # Test inserting a record
            try:
                db.session.execute(db.text("""
                    INSERT INTO daily_followup_count (date, user_id, initial_count)
                    VALUES (CURRENT_DATE, 1, 0) 
                    ON CONFLICT (date, user_id) DO NOTHING;
                """))
                db.session.commit()
                print("✅ Test insert successful!")
                
                # Clean up test record
                db.session.execute(db.text("""
                    DELETE FROM daily_followup_count 
                    WHERE date = CURRENT_DATE AND user_id = 1 AND initial_count = 0;
                """))
                db.session.commit()
                
            except Exception as e:
                print(f"❌ Test insert failed: {e}")
                db.session.rollback()
            
            print("\n" + "=" * 50)
            print("✅ Table fix completed!")
            
            # Verify final structure
            result = db.session.execute(db.text("""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = 'daily_followup_count'
                ORDER BY ordinal_position;
            """)).fetchall()
            
            print("\nFinal table structure:")
            for row in result:
                print(f"  - {row[0]}: {row[1]} (nullable: {row[2]}, default: {row[3]})")
            
    except Exception as e:
        print(f"❌ Error fixing table: {e}")
        sys.exit(1)

if __name__ == '__main__':
    fix_daily_table() 