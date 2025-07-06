#!/usr/bin/env python3
import os
import subprocess
from datetime import datetime
import psycopg2
import csv
from dotenv import load_dotenv
import pytz

# Load environment variables
load_dotenv()

# Database connection parameters
DB_PARAMS = {
    'host': os.getenv('RDS_HOST', 'crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com'),
    'database': os.getenv('RDS_DB', 'crmportal'),
    'user': os.getenv('RDS_USER', 'crmadmin'),
    'password': os.getenv('RDS_PASSWORD', 'GaadiMech2024!'),
    'port': os.getenv('RDS_PORT', '5432')
}

def create_backup_directory():
    """Create backup directory if it doesn't exist"""
    backup_dir = "Database Backup - 6th July"
    csv_dir = os.path.join(backup_dir, "csv_files")
    os.makedirs(csv_dir, exist_ok=True)
    return backup_dir, csv_dir

def backup_sql_dump(backup_dir):
    """Create a complete SQL dump of the database"""
    dump_file = os.path.join(backup_dir, "complete_backup.sql")
    
    # Use PostgreSQL 17 pg_dump
    pg_dump_path = '/usr/local/opt/postgresql@17/bin/pg_dump'
    
    # Construct pg_dump command
    cmd = [
        pg_dump_path,
        '-h', DB_PARAMS['host'],
        '-U', DB_PARAMS['user'],
        '-d', DB_PARAMS['database'],
        '-p', DB_PARAMS['port'],
        '-F', 'p',  # plain text format
        '-f', dump_file
    ]
    
    # Set PGPASSWORD environment variable for password
    env = os.environ.copy()
    env['PGPASSWORD'] = DB_PARAMS['password']
    
    try:
        subprocess.run(cmd, env=env, check=True)
        print(f"✅ SQL dump created successfully: {dump_file}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error creating SQL dump: {e}")
        return False

def backup_tables_to_csv(csv_dir):
    """Backup all tables to CSV files"""
    try:
        # Connect to database
        conn = psycopg2.connect(**DB_PARAMS)
        
        # Set isolation level to SERIALIZABLE for consistent reads
        conn.set_session(isolation_level=psycopg2.extensions.ISOLATION_LEVEL_SERIALIZABLE)
        
        cur = conn.cursor()
        
        # Get list of all tables
        cur.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
            AND table_name != 'users'  -- Exclude the unused 'users' table
        """)
        tables = cur.fetchall()
        
        # Export each table to CSV
        for table in tables:
            table_name = table[0]
            csv_file = os.path.join(csv_dir, f"{table_name}.csv")
            
            # Get column names
            cur.execute(f"""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_schema = 'public' 
                AND table_name = '{table_name}'
                ORDER BY ordinal_position
            """)
            columns = [col[0] for col in cur.fetchall()]
            
            # Export data
            with open(csv_file, 'w', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(columns)  # Write header
                
                # Fetch and write data in chunks using explicit columns
                column_list = ', '.join(f'"{col}"' for col in columns)  # Quote column names
                cur.execute(f'SELECT {column_list} FROM "{table_name}"')  # Quote table name too
                while True:
                    rows = cur.fetchmany(1000)
                    if not rows:
                        break
                    writer.writerows(rows)
            
            # Print row count for verification
            cur.execute(f'SELECT COUNT(*) FROM "{table_name}"')
            count = cur.fetchone()[0]
            print(f"✅ Exported {table_name}: {count} rows")
        
        cur.close()
        conn.close()
        return True
        
    except Exception as e:
        print(f"❌ Error exporting to CSV: {e}")
        return False

def create_backup_info(backup_dir):
    """Create a backup info file with timestamp and database details"""
    info_file = os.path.join(backup_dir, "backup_info.txt")
    ist = pytz.timezone('Asia/Kolkata')
    timestamp = datetime.now(ist).strftime("%Y-%m-%d %H:%M:%S %Z")
    
    with open(info_file, 'w') as f:
        f.write("GaadiMech CRM Database Backup\n")
        f.write("============================\n\n")
        f.write(f"Backup created at: {timestamp}\n")
        f.write(f"Database host: {DB_PARAMS['host']}\n")
        f.write(f"Database name: {DB_PARAMS['database']}\n")
        f.write(f"Backup format: SQL dump and CSV files\n")

def main():
    print("Starting database backup process...")
    
    # Create backup directories
    backup_dir, csv_dir = create_backup_directory()
    print(f"Created backup directory: {backup_dir}")
    
    # Create SQL dump
    if not backup_sql_dump(backup_dir):
        print("Failed to create SQL dump")
    
    # Export tables to CSV
    if not backup_tables_to_csv(csv_dir):
        print("Failed to export tables to CSV")
    
    # Create backup info file
    create_backup_info(backup_dir)
    
    print("\nBackup process completed!")
    print(f"Backup files are stored in: {backup_dir}")
    print("- SQL dump: complete_backup.sql")
    print("- CSV files: csv_files/")
    print("- Backup info: backup_info.txt")

if __name__ == "__main__":
    main() 