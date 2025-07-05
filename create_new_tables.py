#!/usr/bin/env python3

"""
Migration script to add new tables for admin leads functionality.
This script creates UnassignedLead and TeamAssignment tables.
"""

from application import application, db
from datetime import datetime

def create_new_tables():
    """Create the new tables for admin leads functionality."""
    with application.app_context():
        try:
            # Create all tables (this will create new ones and skip existing ones)
            db.create_all()
            print("✅ Database tables created successfully!")
            
            # Test the new models
            from application import UnassignedLead, TeamAssignment, User
            
            # Check if tables exist by querying them
            unassigned_count = UnassignedLead.query.count()
            assignment_count = TeamAssignment.query.count()
            
            print(f"✅ UnassignedLead table exists with {unassigned_count} records")
            print(f"✅ TeamAssignment table exists with {assignment_count} records")
            
            # Check if we have users (for testing)
            user_count = User.query.count()
            print(f"✅ User table has {user_count} users")
            
            print("\n🎉 Migration completed successfully!")
            print("The new admin leads functionality is ready to use.")
            
        except Exception as e:
            print(f"❌ Error during migration: {str(e)}")
            raise

if __name__ == "__main__":
    create_new_tables() 