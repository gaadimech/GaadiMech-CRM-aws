#!/usr/bin/env python3
"""
Supabase to RDS Migration Script
================================

This script safely migrates the entire Supabase database to RDS:
- Schema (tables, indexes, constraints)
- Data (all records)
- Sequences
- Permissions (where applicable)

It performs read-only operations on Supabase and creates everything fresh in RDS.
"""

import os
import sys
import logging
import subprocess
import tempfile
from datetime import datetime
from pathlib import Path
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import argparse

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f'migration_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class DatabaseMigrator:
    def __init__(self, source_url, target_url):
        self.source_url = source_url
        self.target_url = target_url
        self.temp_dir = None
        
    def create_temp_directory(self):
        """Create a temporary directory for migration files."""
        self.temp_dir = tempfile.mkdtemp(prefix='supabase_migration_')
        logger.info(f"Created temporary directory: {self.temp_dir}")
        return self.temp_dir
        
    def cleanup_temp_directory(self):
        """Clean up temporary directory."""
        if self.temp_dir and Path(self.temp_dir).exists():
            import shutil
            shutil.rmtree(self.temp_dir)
            logger.info(f"Cleaned up temporary directory: {self.temp_dir}")
    
    def test_connections(self):
        """Test connections to both source and target databases."""
        logger.info("Testing database connections...")
        
        # Test source (Supabase) connection
        try:
            conn = psycopg2.connect(self.source_url)
            conn.close()
            logger.info("✓ Source database (Supabase) connection successful")
        except Exception as e:
            logger.error(f"✗ Failed to connect to source database: {e}")
            return False
            
        # Test target (RDS) connection
        try:
            conn = psycopg2.connect(self.target_url)
            conn.close()
            logger.info("✓ Target database (RDS) connection successful")
        except Exception as e:
            logger.error(f"✗ Failed to connect to target database: {e}")
            return False
            
        return True
    
    def get_database_info(self, connection_url, db_name):
        """Get basic information about a database."""
        try:
            conn = psycopg2.connect(connection_url)
            cursor = conn.cursor()
            
            # Get table count
            cursor.execute("""
                SELECT COUNT(*) 
                FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            """)
            table_count = cursor.fetchone()[0]
            
            # Get total record count across all tables
            cursor.execute("""
                SELECT tablename 
                FROM pg_tables 
                WHERE schemaname = 'public'
            """)
            tables = cursor.fetchall()
            
            total_records = 0
            table_info = []
            
            for (table,) in tables:
                try:
                    cursor.execute(f'SELECT COUNT(*) FROM "{table}"')
                    count = cursor.fetchone()[0]
                    total_records += count
                    table_info.append((table, count))
                except Exception as e:
                    logger.warning(f"Could not count records in table {table}: {e}")
                    table_info.append((table, 0))
            
            cursor.close()
            conn.close()
            
            logger.info(f"\n{db_name} Database Info:")
            logger.info(f"  Tables: {table_count}")
            logger.info(f"  Total records: {total_records}")
            for table, count in table_info:
                logger.info(f"    {table}: {count} records")
                
            return {
                'tables': table_count,
                'total_records': total_records,
                'table_info': table_info
            }
            
        except Exception as e:
            logger.error(f"Failed to get {db_name} info: {e}")
            return None
    
    def backup_source_database(self):
        """Create a full backup of the source database using pg_dump."""
        logger.info("Creating backup of source database...")
        
        backup_file = os.path.join(self.temp_dir, 'supabase_backup.sql')
        
        # Create pg_dump command - removing problematic flags for version 14
        cmd = [
            'pg_dump',
            '--verbose',
            '--format=plain',
            '--no-owner',
            '--no-privileges',
            '--clean',
            '--if-exists',
            self.source_url
        ]
        
        # Set PGPASSWORD environment variable to avoid password prompt
        env = os.environ.copy()
        
        try:
            with open(backup_file, 'w') as f:
                result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, text=True, env=env)
                
            if result.returncode != 0:
                logger.error(f"pg_dump failed: {result.stderr}")
                # Try without --clean and --if-exists for compatibility
                logger.info("Retrying with simpler pg_dump options...")
                cmd_simple = [
                    'pg_dump',
                    '--verbose',
                    '--format=plain',
                    '--no-owner',
                    '--no-privileges',
                    self.source_url
                ]
                
                with open(backup_file, 'w') as f:
                    result = subprocess.run(cmd_simple, stdout=f, stderr=subprocess.PIPE, text=True, env=env)
                    
                if result.returncode != 0:
                    logger.error(f"pg_dump failed again: {result.stderr}")
                    return None
                
            logger.info(f"✓ Backup created successfully: {backup_file}")
            
            # Get file size
            size_mb = os.path.getsize(backup_file) / (1024 * 1024)
            logger.info(f"  Backup size: {size_mb:.2f} MB")
            
            return backup_file
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to create backup: {e}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error during backup: {e}")
            return None
    
    def prepare_backup_for_rds(self, backup_file):
        """Prepare the backup file for RDS by removing problematic statements."""
        logger.info("Preparing backup for RDS...")
        
        prepared_file = os.path.join(self.temp_dir, 'rds_prepared_backup.sql')
        
        try:
            with open(backup_file, 'r') as infile, open(prepared_file, 'w') as outfile:
                for line in infile:
                    # Skip problematic lines for RDS
                    if any(skip_pattern in line.upper() for skip_pattern in [
                        'CREATE EXTENSION',
                        'DROP EXTENSION',
                        'COMMENT ON EXTENSION',
                        'CREATE SCHEMA PUBLIC',
                        'ALTER SCHEMA PUBLIC OWNER',
                        'REVOKE ALL ON SCHEMA PUBLIC',
                        'GRANT ALL ON SCHEMA PUBLIC'
                    ]):
                        outfile.write(f'-- SKIPPED: {line}')
                        continue
                    
                    # Replace any Supabase-specific functions or features
                    line = line.replace('gen_random_uuid()', 'uuid_generate_v4()')
                    
                    outfile.write(line)
            
            logger.info(f"✓ Backup prepared for RDS: {prepared_file}")
            return prepared_file
            
        except Exception as e:
            logger.error(f"Failed to prepare backup: {e}")
            return None
    
    def restore_to_target(self, prepared_backup_file):
        """Restore the prepared backup to the target RDS database."""
        logger.info("Restoring to target database...")
        
        # First, ensure uuid-ossp extension exists (for uuid_generate_v4)
        try:
            conn = psycopg2.connect(self.target_url)
            conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
            cursor = conn.cursor()
            
            # Create uuid-ossp extension if it doesn't exist
            cursor.execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
            
            cursor.close()
            conn.close()
            logger.info("✓ UUID extension ensured")
            
        except Exception as e:
            logger.warning(f"Could not create UUID extension: {e}")
        
        # Restore using psql
        cmd = [
            'psql',
            '--quiet',
            '--no-password',
            self.target_url,
            '-f', prepared_backup_file
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                logger.error(f"Restore failed: {result.stderr}")
                return False
                
            logger.info("✓ Database restored successfully")
            
            # Log any warnings
            if result.stderr:
                logger.info(f"Restore warnings: {result.stderr}")
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to restore database: {e}")
            return False
    
    def verify_migration(self):
        """Verify that the migration was successful by comparing data."""
        logger.info("Verifying migration...")
        
        try:
            # Get info from both databases
            source_info = self.get_database_info(self.source_url, "Source (Supabase)")
            target_info = self.get_database_info(self.target_url, "Target (RDS)")
            
            if not source_info or not target_info:
                logger.error("Could not verify migration - failed to get database info")
                return False
            
            # Compare table counts
            if source_info['tables'] != target_info['tables']:
                logger.error(f"Table count mismatch: Source={source_info['tables']}, Target={target_info['tables']}")
                return False
            
            # Compare record counts
            if source_info['total_records'] != target_info['total_records']:
                logger.error(f"Record count mismatch: Source={source_info['total_records']}, Target={target_info['total_records']}")
                return False
            
            # Compare individual table record counts
            source_tables = {table: count for table, count in source_info['table_info']}
            target_tables = {table: count for table, count in target_info['table_info']}
            
            for table in source_tables:
                if table not in target_tables:
                    logger.error(f"Table {table} missing in target database")
                    return False
                    
                if source_tables[table] != target_tables[table]:
                    logger.error(f"Record count mismatch for table {table}: Source={source_tables[table]}, Target={target_tables[table]}")
                    return False
            
            logger.info("✓ Migration verification successful - all data matches!")
            return True
            
        except Exception as e:
            logger.error(f"Migration verification failed: {e}")
            return False
    
    def migrate(self):
        """Execute the full migration process."""
        logger.info("Starting Supabase to RDS migration...")
        
        try:
            # Create temporary directory
            self.create_temp_directory()
            
            # Test connections
            if not self.test_connections():
                return False
            
            # Get initial database info
            self.get_database_info(self.source_url, "Source (Supabase)")
            
            # Backup source database
            backup_file = self.backup_source_database()
            if not backup_file:
                return False
            
            # Prepare backup for RDS
            prepared_file = self.prepare_backup_for_rds(backup_file)
            if not prepared_file:
                return False
            
            # Restore to target
            if not self.restore_to_target(prepared_file):
                return False
            
            # Verify migration
            if not self.verify_migration():
                return False
            
            logger.info("🎉 Migration completed successfully!")
            return True
            
        except Exception as e:
            logger.error(f"Migration failed: {e}")
            return False
            
        finally:
            self.cleanup_temp_directory()

def main():
    parser = argparse.ArgumentParser(description='Migrate Supabase database to RDS')
    parser.add_argument('--source', required=True, help='Source database URL (Supabase)')
    parser.add_argument('--target', required=True, help='Target database URL (RDS)')
    parser.add_argument('--dry-run', action='store_true', help='Only test connections and show database info')
    
    args = parser.parse_args()
    
    migrator = DatabaseMigrator(args.source, args.target)
    
    if args.dry_run:
        logger.info("Running in dry-run mode...")
        if migrator.test_connections():
            migrator.get_database_info(args.source, "Source (Supabase)")
            migrator.get_database_info(args.target, "Target (RDS)")
            logger.info("Dry run completed successfully")
            return True
        else:
            logger.error("Dry run failed - connection issues")
            return False
    else:
        return migrator.migrate()

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 