#!/usr/bin/env python3
"""
Pure Python Supabase to RDS Migration Script
============================================

This script uses only Python and psycopg2 to avoid PostgreSQL version compatibility issues.
It performs the same migration but with direct database queries instead of pg_dump.
"""

import os
import sys
import logging
from datetime import datetime
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import argparse

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f'python_migration_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class PythonDatabaseMigrator:
    def __init__(self, source_url, target_url):
        self.source_url = source_url
        self.target_url = target_url
        
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
            
            # Get tables
            cursor.execute("""
                SELECT tablename 
                FROM pg_tables 
                WHERE schemaname = 'public'
                ORDER BY tablename
            """)
            tables = cursor.fetchall()
            
            total_records = 0
            table_info = []
            
            for (table,) in tables:
                try:
                    # Use a fresh cursor for each table to avoid transaction issues
                    table_cursor = conn.cursor()
                    table_cursor.execute(f'SELECT COUNT(*) FROM "{table}"')
                    count = table_cursor.fetchone()[0]
                    total_records += count
                    table_info.append((table, count))
                    table_cursor.close()
                except Exception as e:
                    logger.warning(f"Could not count records in table {table}: {e}")
                    # Rollback the transaction and continue
                    conn.rollback()
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
    
    def get_table_schema(self, source_conn, table_name):
        """Get the CREATE TABLE statement for a table."""
        cursor = source_conn.cursor()
        
        # Get table definition using information_schema
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default, character_maximum_length
            FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = %s
            ORDER BY ordinal_position
        """, (table_name,))
        
        columns = cursor.fetchall()
        
        if not columns:
            return None
            
        # Build CREATE TABLE statement
        create_sql = f'CREATE TABLE "{table_name}" (\n'
        column_defs = []
        
        for col_name, data_type, is_nullable, col_default, char_max_len in columns:
            col_def = f'    "{col_name}" '
            
            # Handle serial columns (auto-increment)
            if col_default and 'nextval(' in str(col_default):
                if data_type == 'integer':
                    col_def += 'SERIAL'
                elif data_type == 'bigint':
                    col_def += 'BIGSERIAL'
                else:
                    col_def += data_type
                    if char_max_len:
                        col_def += f'({char_max_len})'
            else:
                col_def += data_type
                if char_max_len:
                    col_def += f'({char_max_len})'
                    
            if is_nullable == 'NO':
                col_def += ' NOT NULL'
                
            # Only add DEFAULT if it's not a sequence
            if col_default and 'nextval(' not in str(col_default):
                col_def += f' DEFAULT {col_default}'
                
            column_defs.append(col_def)
        
        create_sql += ',\n'.join(column_defs)
        create_sql += '\n);'
        
        return create_sql
    
    def get_table_constraints(self, source_conn, table_name):
        """Get constraints for a table."""
        cursor = source_conn.cursor()
        constraints = []
        
        # Get primary key constraints
        cursor.execute("""
            SELECT tc.constraint_name, kcu.column_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
            WHERE tc.table_schema = 'public' AND tc.table_name = %s AND tc.constraint_type = 'PRIMARY KEY'
        """, (table_name,))
        
        pk_results = cursor.fetchall()
        if pk_results:
            pk_columns = [row[1] for row in pk_results]
            pk_cols_str = ", ".join(f'"{col}"' for col in pk_columns)
            constraints.append(f'ALTER TABLE "{table_name}" ADD PRIMARY KEY ({pk_cols_str});')
        
        # Get foreign key constraints
        cursor.execute("""
            SELECT tc.constraint_name, kcu.column_name, ccu.table_name, ccu.column_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
            WHERE tc.table_schema = 'public' AND tc.table_name = %s AND tc.constraint_type = 'FOREIGN KEY'
        """, (table_name,))
        
        fk_results = cursor.fetchall()
        for constraint_name, column_name, ref_table, ref_column in fk_results:
            constraints.append(f'ALTER TABLE "{table_name}" ADD CONSTRAINT "{constraint_name}" FOREIGN KEY ("{column_name}") REFERENCES "{ref_table}"("{ref_column}");')
        
        return constraints
    
    def copy_table_data(self, source_conn, target_conn, table_name):
        """Copy data from source table to target table."""
        source_cursor = source_conn.cursor()
        target_cursor = target_conn.cursor()
        
        # Get column names
        source_cursor.execute("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = %s
            ORDER BY ordinal_position
        """, (table_name,))
        
        columns = [row[0] for row in source_cursor.fetchall()]
        
        if not columns:
            logger.warning(f"No columns found for table {table_name}")
            return 0
            
        # Copy data in batches
        batch_size = 1000
        offset = 0
        total_copied = 0
        
        column_names = ', '.join(f'"{col}"' for col in columns)
        placeholders = ', '.join(['%s'] * len(columns))
        
        while True:
            # Fetch batch from source
            source_cursor.execute(f'SELECT {column_names} FROM "{table_name}" LIMIT %s OFFSET %s', (batch_size, offset))
            rows = source_cursor.fetchall()
            
            if not rows:
                break
                
            # Insert batch into target
            insert_sql = f'INSERT INTO "{table_name}" ({column_names}) VALUES ({placeholders})'
            target_cursor.executemany(insert_sql, rows)
            target_conn.commit()
            
            total_copied += len(rows)
            offset += batch_size
            
            if len(rows) < batch_size:
                break
                
        logger.info(f"  Copied {total_copied} records")
        return total_copied
    
    def migrate_table(self, source_conn, target_conn, table_name):
        """Migrate a single table (schema and data)."""
        logger.info(f"Migrating table: {table_name}")
        
        target_cursor = target_conn.cursor()
        
        # Drop table if exists
        target_cursor.execute(f'DROP TABLE IF EXISTS "{table_name}" CASCADE')
        target_conn.commit()
        
        # Create table
        create_sql = self.get_table_schema(source_conn, table_name)
        if not create_sql:
            logger.error(f"Could not get schema for table {table_name}")
            return False
            
        target_cursor.execute(create_sql)
        target_conn.commit()
        
        # Copy data
        copied_count = self.copy_table_data(source_conn, target_conn, table_name)
        
        return True
    
    def apply_constraints(self, source_conn, target_conn, table_names):
        """Apply constraints after all tables are created."""
        logger.info("Applying constraints...")
        
        target_cursor = target_conn.cursor()
        
        for table_name in table_names:
            constraints = self.get_table_constraints(source_conn, table_name)
            for constraint_sql in constraints:
                try:
                    target_cursor.execute(constraint_sql)
                    target_conn.commit()
                except Exception as e:
                    logger.warning(f"Could not apply constraint: {constraint_sql[:50]}... Error: {e}")
    
    def migrate(self):
        """Execute the migration process."""
        logger.info("Starting Python-based Supabase to RDS migration...")
        
        try:
            # Test connections
            if not self.test_connections():
                return False
            
            # Get source database info
            source_info = self.get_database_info(self.source_url, "Source (Supabase)")
            if not source_info:
                return False
            
            # Connect to both databases
            source_conn = psycopg2.connect(self.source_url)
            target_conn = psycopg2.connect(self.target_url)
            target_conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
            
            # Get list of tables to migrate
            tables_to_migrate = [table for table, count in source_info['table_info'] if table != 'users']
            
            logger.info(f"Migrating {len(tables_to_migrate)} tables...")
            
            # Migrate each table (schema and data)
            for table_name, _ in source_info['table_info']:
                if table_name == 'users':  # Skip existing users table in RDS
                    continue
                    
                if not self.migrate_table(source_conn, target_conn, table_name):
                    logger.error(f"Failed to migrate table {table_name}")
                    return False
            
            # Apply constraints
            self.apply_constraints(source_conn, target_conn, tables_to_migrate)
            
            # Close connections
            source_conn.close()
            target_conn.close()
            
            # Verify migration
            if not self.verify_migration():
                return False
            
            logger.info("🎉 Migration completed successfully!")
            return True
            
        except Exception as e:
            logger.error(f"Migration failed: {e}")
            return False
    
    def verify_migration(self):
        """Verify that the migration was successful."""
        logger.info("Verifying migration...")
        
        try:
            source_info = self.get_database_info(self.source_url, "Source (Supabase)")
            target_info = self.get_database_info(self.target_url, "Target (RDS)")
            
            if not source_info or not target_info:
                logger.error("Could not verify migration - failed to get database info")
                return False
            
            # Compare record counts for each table (excluding users table)
            source_tables = {table: count for table, count in source_info['table_info'] if table != 'users'}
            target_tables = {table: count for table, count in target_info['table_info']}
            
            for table in source_tables:
                if table not in target_tables:
                    logger.error(f"Table {table} missing in target database")
                    return False
                    
                if source_tables[table] != target_tables[table]:
                    logger.error(f"Record count mismatch for table {table}: Source={source_tables[table]}, Target={target_tables[table]}")
                    return False
            
            logger.info("✓ Migration verification successful!")
            return True
            
        except Exception as e:
            logger.error(f"Migration verification failed: {e}")
            return False

def main():
    parser = argparse.ArgumentParser(description='Python-based Supabase to RDS migration')
    parser.add_argument('--source', required=True, help='Source database URL (Supabase)')
    parser.add_argument('--target', required=True, help='Target database URL (RDS)')
    parser.add_argument('--dry-run', action='store_true', help='Only test connections and show database info')
    
    args = parser.parse_args()
    
    migrator = PythonDatabaseMigrator(args.source, args.target)
    
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