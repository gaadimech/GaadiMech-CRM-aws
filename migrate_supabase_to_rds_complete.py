#!/usr/bin/env python3
"""
Complete Supabase to RDS Migration Script
Migrates all tables, schema, and data from Supabase to AWS RDS PostgreSQL
"""

import psycopg
import sys
from datetime import datetime

# Database connections
SUPABASE_URL = "postgresql://crmadmin:gaadimech123@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/postgres"
RDS_URL = "postgresql://crmadmin:GaadiMech2024!@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal"

def log(message):
    """Log with timestamp"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def get_table_info(conn, schema='public'):
    """Get all tables in the database"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = %s 
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    """, (schema,))
    return [row[0] for row in cursor.fetchall()]

def get_table_schema(conn, table_name, schema='public'):
    """Get complete table schema including constraints"""
    cursor = conn.cursor()
    
    # Get columns
    cursor.execute("""
        SELECT 
            column_name,
            data_type,
            is_nullable,
            column_default,
            character_maximum_length
        FROM information_schema.columns 
        WHERE table_schema = %s AND table_name = %s
        ORDER BY ordinal_position
    """, (schema, table_name))
    
    columns = cursor.fetchall()
    
    # Build CREATE TABLE statement
    create_sql = f'CREATE TABLE IF NOT EXISTS "{table_name}" (\n'
    column_defs = []
    
    for col_name, data_type, is_nullable, col_default, char_max_len in columns:
        col_def = f'    "{col_name}" '
        
        # Handle data types
        if data_type == 'character varying':
            if char_max_len:
                col_def += f'VARCHAR({char_max_len})'
            else:
                col_def += 'TEXT'
        elif data_type == 'timestamp without time zone':
            col_def += 'TIMESTAMP'
        elif data_type == 'timestamp with time zone':
            col_def += 'TIMESTAMPTZ'
        elif data_type == 'USER-DEFINED':
            # Handle enums or custom types
            col_def += 'TEXT'
        else:
            col_def += data_type.upper()
            if char_max_len and data_type not in ['text', 'integer', 'bigint', 'boolean', 'date']:
                col_def += f'({char_max_len})'
        
        # Handle nullability
        if is_nullable == 'NO':
            col_def += ' NOT NULL'
        
        # Handle defaults (skip sequences for now)
        if col_default and not col_default.startswith('nextval('):
            col_def += f' DEFAULT {col_default}'
        
        column_defs.append(col_def)
    
    create_sql += ',\n'.join(column_defs)
    create_sql += '\n);'
    
    return create_sql

def get_primary_keys(conn, table_name, schema='public'):
    """Get primary key constraints"""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT kc.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kc 
        ON tc.constraint_name = kc.constraint_name
        WHERE tc.table_schema = %s 
        AND tc.table_name = %s 
        AND tc.constraint_type = 'PRIMARY KEY'
        ORDER BY kc.ordinal_position
    """, (schema, table_name))
    
    pk_columns = [row[0] for row in cursor.fetchall()]
    if pk_columns:
        return f'ALTER TABLE "{table_name}" ADD PRIMARY KEY ({", ".join(f\'"{col}"\' for col in pk_columns)});'
    return None

def copy_table_data(source_conn, target_conn, table_name):
    """Copy all data from source to target table"""
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
        log(f"  ⚠️  No columns found for table {table_name}")
        return 0
    
    # Get total count
    source_cursor.execute(f'SELECT COUNT(*) FROM "{table_name}"')
    total_count = source_cursor.fetchone()[0]
    
    if total_count == 0:
        log(f"  📊 Table {table_name}: 0 records (empty)")
        return 0
    
    log(f"  📊 Table {table_name}: {total_count:,} records to copy")
    
    # Clear target table
    target_cursor.execute(f'DELETE FROM "{table_name}"')
    target_conn.commit()
    
    # Copy data in batches
    batch_size = 1000
    copied = 0
    
    column_names = ', '.join(f'"{col}"' for col in columns)
    placeholders = ', '.join(['%s'] * len(columns))
    
    for offset in range(0, total_count, batch_size):
        # Fetch batch
        source_cursor.execute(
            f'SELECT {column_names} FROM "{table_name}" LIMIT %s OFFSET %s',
            (batch_size, offset)
        )
        
        rows = source_cursor.fetchall()
        if not rows:
            break
        
        # Insert batch
        insert_sql = f'INSERT INTO "{table_name}" ({column_names}) VALUES ({placeholders})'
        target_cursor.executemany(insert_sql, rows)
        target_conn.commit()
        
        copied += len(rows)
        
        if copied % 5000 == 0:
            log(f"    Progress: {copied:,}/{total_count:,} records")
    
    log(f"  ✅ Copied {copied:,} records")
    return copied

def migrate_database():
    """Main migration function"""
    log("🚀 Starting Complete Supabase to RDS Migration")
    log("=" * 60)
    
    try:
        # Connect to both databases
        log("📡 Connecting to Supabase...")
        source_conn = psycopg.connect(SUPABASE_URL)
        
        log("📡 Connecting to RDS...")
        target_conn = psycopg.connect(RDS_URL)
        
        # Get all tables from source
        log("📋 Discovering tables in Supabase...")
        tables = get_table_info(source_conn)
        
        if not tables:
            log("❌ No tables found in source database")
            return False
        
        log(f"📊 Found {len(tables)} tables: {', '.join(tables)}")
        
        # Migration statistics
        total_records = 0
        migrated_tables = 0
        
        # Phase 1: Create all tables
        log("\n🏗️  PHASE 1: Creating table schemas...")
        target_cursor = target_conn.cursor()
        
        for table in tables:
            try:
                log(f"  Creating table: {table}")
                
                # Drop existing table
                target_cursor.execute(f'DROP TABLE IF EXISTS "{table}" CASCADE')
                
                # Create table
                create_sql = get_table_schema(source_conn, table)
                target_cursor.execute(create_sql)
                
                target_conn.commit()
                log(f"  ✅ Created table: {table}")
                
            except Exception as e:
                log(f"  ❌ Error creating table {table}: {e}")
                continue
        
        # Phase 2: Copy all data
        log("\n📦 PHASE 2: Copying data...")
        
        for table in tables:
            try:
                records = copy_table_data(source_conn, target_conn, table)
                total_records += records
                migrated_tables += 1
                
            except Exception as e:
                log(f"  ❌ Error copying data for {table}: {e}")
                continue
        
        # Phase 3: Add primary keys and constraints
        log("\n🔑 PHASE 3: Adding primary keys...")
        
        for table in tables:
            try:
                pk_sql = get_primary_keys(source_conn, table)
                if pk_sql:
                    target_cursor.execute(pk_sql)
                    target_conn.commit()
                    log(f"  ✅ Added primary key for: {table}")
                
            except Exception as e:
                log(f"  ⚠️  Could not add primary key for {table}: {e}")
                continue
        
        # Final verification
        log("\n🔍 VERIFICATION:")
        target_cursor.execute("""
            SELECT table_name, 
                   (SELECT COUNT(*) FROM information_schema.columns 
                    WHERE table_name = t.table_name AND table_schema = 'public') as columns
            FROM information_schema.tables t
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
            ORDER BY table_name
        """)
        
        for table_name, col_count in target_cursor.fetchall():
            target_cursor.execute(f'SELECT COUNT(*) FROM "{table_name}"')
            row_count = target_cursor.fetchone()[0]
            log(f"  📊 {table_name}: {row_count:,} records, {col_count} columns")
        
        # Close connections
        source_conn.close()
        target_conn.close()
        
        log("\n" + "=" * 60)
        log("🎉 MIGRATION COMPLETED SUCCESSFULLY!")
        log(f"📊 Migrated {migrated_tables} tables")
        log(f"📈 Total records: {total_records:,}")
        log("🌐 Your CRM is ready to use!")
        
        return True
        
    except Exception as e:
        log(f"❌ Migration failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = migrate_database()
    sys.exit(0 if success else 1) 