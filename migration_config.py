#!/usr/bin/env python3
"""
Migration Configuration
========================

Configuration settings for the Supabase to RDS migration.
Edit the database URLs here and then run the migration.
"""

# Source Database (Supabase) - READ ONLY
SUPABASE_URL = "postgresql://postgres.qcvfmiqzkfhinxlhknnd:gaadimech123@aws-0-ap-south-1.pooler.supabase.com:6543/postgres"

# Target Database (RDS) - This should be your new RDS instance
# Update these with your actual RDS credentials
RDS_HOST = "gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com"
RDS_DB = "crmportal"
RDS_USER = "postgres"
RDS_PASSWORD = "GaadiMech2024!"
RDS_PORT = "5432"

# Build RDS URL
RDS_URL = f"postgresql://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"

# Configuration validation
def validate_config():
    """Validate that all required configuration is present."""
    if not SUPABASE_URL or not RDS_URL:
        raise ValueError("Both SUPABASE_URL and RDS_URL must be configured")
    
    if "gaadimech123" not in SUPABASE_URL:
        raise ValueError("Supabase URL appears to be incorrect")
    
    if not all([RDS_HOST, RDS_DB, RDS_USER, RDS_PASSWORD]):
        raise ValueError("All RDS configuration parameters must be set")
    
    return True

if __name__ == "__main__":
    try:
        validate_config()
        print("✓ Configuration is valid")
        print(f"Source (Supabase): {SUPABASE_URL[:50]}...")
        print(f"Target (RDS): {RDS_URL[:50]}...")
    except ValueError as e:
        print(f"✗ Configuration error: {e}") 