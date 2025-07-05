#!/usr/bin/env python3

"""
Migration script to fix mobile field length in database.
This script updates the mobile field from VARCHAR(12) to VARCHAR(15).
"""

from application import application, db
from sqlalchemy import text

def fix_mobile_length():
    """Update mobile field length in both Lead and UnassignedLead tables."""
    with application.app_context():
        try:
            # Get the database engine
            engine = db.engine
            
            # Update Lead table mobile field length
            print("Updating Lead table mobile field...")
            with engine.connect() as conn:
                conn.execute(text("ALTER TABLE lead ALTER COLUMN mobile TYPE VARCHAR(15)"))
                conn.commit()
                print("✅ Lead table mobile field updated to VARCHAR(15)")
            
            # Update UnassignedLead table mobile field length
            print("Updating UnassignedLead table mobile field...")
            with engine.connect() as conn:
                conn.execute(text("ALTER TABLE unassigned_lead ALTER COLUMN mobile TYPE VARCHAR(15)"))
                conn.commit()
                print("✅ UnassignedLead table mobile field updated to VARCHAR(15)")
            
            print("\n🎉 Mobile field length update completed successfully!")
            print("The database can now handle mobile numbers up to 15 characters.")
            
        except Exception as e:
            print(f"❌ Error during migration: {str(e)}")
            raise

if __name__ == "__main__":
    fix_mobile_length() 