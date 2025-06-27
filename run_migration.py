#!/usr/bin/env python3
"""
Migration Runner
================

Simple script to run the Supabase to RDS migration using the configured settings.
"""

import sys
import subprocess
from migration_config import SUPABASE_URL, RDS_URL, validate_config

def run_migration(dry_run=False):
    """Run the migration with the configured settings."""
    try:
        # Validate configuration first
        validate_config()
        print("✓ Configuration validated")
        
        # Build command
        cmd = [
            sys.executable,  # Use current Python interpreter
            "migrate_supabase_to_rds.py",
            "--source", SUPABASE_URL,
            "--target", RDS_URL
        ]
        
        if dry_run:
            cmd.append("--dry-run")
            print("Running in DRY RUN mode (no actual migration will happen)...")
        else:
            print("Starting ACTUAL migration...")
            
        # Run the migration
        result = subprocess.run(cmd)
        return result.returncode == 0
        
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Run Supabase to RDS migration')
    parser.add_argument('--dry-run', action='store_true', 
                       help='Test connections and show info without migrating')
    
    args = parser.parse_args()
    
    print("🚀 Supabase to RDS Migration Runner")
    print("=" * 40)
    
    success = run_migration(dry_run=args.dry_run)
    
    if success:
        if args.dry_run:
            print("\n✅ Dry run completed successfully!")
            print("Run without --dry-run to perform actual migration.")
        else:
            print("\n🎉 Migration completed successfully!")
    else:
        print("\n❌ Migration failed. Check the logs for details.")
        sys.exit(1)

if __name__ == "__main__":
    main() 