#!/usr/bin/env python3
"""
Copy data from postgres database to crmportal database
"""

import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

# Database URLs
POSTGRES_URL = "postgresql://postgres:GaadiMech2024!@gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/postgres"
CRMPORTAL_URL = "postgresql://postgres:GaadiMech2024!@gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal"

def copy_data():
    """Copy all data from postgres to crmportal database"""
    try:
        # Create crmportal database if it doesn't exist
        postgres_conn = psycopg2.connect("postgresql://postgres:GaadiMech2024!@gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/postgres")
        postgres_conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        postgres_cursor = postgres_conn.cursor()
        
        # Check if crmportal exists
        postgres_cursor.execute("SELECT 1 FROM pg_database WHERE datname = 'crmportal'")
        if not postgres_cursor.fetchone():
            print("Creating crmportal database...")
            postgres_cursor.execute("CREATE DATABASE crmportal")
            print("✅ crmportal database created")
        else:
            print("✅ crmportal database already exists")
        
        postgres_conn.close()
        
        # Connect to both databases
        print("\n🔗 Connecting to databases...")
        source_conn = psycopg2.connect(POSTGRES_URL)
        target_conn = psycopg2.connect(CRMPORTAL_URL)
        
        source_cursor = source_conn.cursor()
        target_cursor = target_conn.cursor()
        
        # Get tables from source
        source_cursor.execute("""
            SELECT tablename FROM pg_tables 
            WHERE schemaname = 'public' 
            ORDER BY tablename
        """)
        tables = [row[0] for row in source_cursor.fetchall()]
        
        print(f"📋 Found tables: {tables}")
        
        for table in tables:
            print(f"\n📦 Processing table: {table}")
            
            # Get table structure
            source_cursor.execute(f"""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_name = '{table}' AND table_schema = 'public'
                ORDER BY ordinal_position
            """)
            columns = source_cursor.fetchall()
            
            # Create table in target
            column_defs = []
            for col_name, data_type, is_nullable, default in columns:
                col_def = f"{col_name} {data_type}"
                if is_nullable == 'NO':
                    col_def += " NOT NULL"
                if default:
                    col_def += f" DEFAULT {default}"
                column_defs.append(col_def)
            
            create_sql = f"CREATE TABLE IF NOT EXISTS {table} ({', '.join(column_defs)})"
            target_cursor.execute(create_sql)
            
            # Copy data
            source_cursor.execute(f"SELECT * FROM {table}")
            rows = source_cursor.fetchall()
            
            if rows:
                # Clear existing data
                target_cursor.execute(f"DELETE FROM {table}")
                
                # Get column names for insert
                col_names = [col[0] for col in columns]
                placeholders = ', '.join(['%s'] * len(col_names))
                insert_sql = f"INSERT INTO {table} ({', '.join(col_names)}) VALUES ({placeholders})"
                
                target_cursor.executemany(insert_sql, rows)
                print(f"   ✅ Copied {len(rows)} records")
            else:
                print(f"   ⚠️ No data to copy")
        
        # Copy constraints and indexes
        print("\n🔐 Copying constraints...")
        
        # Primary keys
        source_cursor.execute("""
            SELECT tc.table_name, tc.constraint_name, kcu.column_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu 
                ON tc.constraint_name = kcu.constraint_name
            WHERE tc.constraint_type = 'PRIMARY KEY' 
            AND tc.table_schema = 'public'
        """)
        
        for table_name, constraint_name, column_name in source_cursor.fetchall():
            try:
                target_cursor.execute(f"ALTER TABLE {table_name} ADD PRIMARY KEY ({column_name})")
                print(f"   ✅ Added primary key to {table_name}")
            except Exception as e:
                print(f"   ⚠️ Primary key already exists for {table_name}")
        
        # Commit all changes
        target_conn.commit()
        
        # Verify the copy
        print("\n🔍 Verification:")
        for table in tables:
            source_cursor.execute(f"SELECT COUNT(*) FROM {table}")
            source_count = source_cursor.fetchone()[0]
            
            target_cursor.execute(f"SELECT COUNT(*) FROM {table}")
            target_count = target_cursor.fetchone()[0]
            
            if source_count == target_count:
                print(f"   ✅ {table}: {target_count} records (matches source)")
            else:
                print(f"   ❌ {table}: {target_count} records (source has {source_count})")
        
        source_conn.close()
        target_conn.close()
        
        print("\n🎉 Data copy completed successfully!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    copy_data() 