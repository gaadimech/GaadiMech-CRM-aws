#!/usr/bin/env python3
import psycopg2
import os
from datetime import datetime

# RDS connection details
RDS_HOST = "gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com"
RDS_USER = "postgres"
RDS_PASSWORD = "GaadiMech2024!"
RDS_PORT = 5432
RDS_DB = "postgres"  # Using default postgres database

def test_connection():
    """Test database connection and basic operations"""
    try:
        print("🔗 Testing connection to AWS RDS PostgreSQL...")
        print(f"Host: {RDS_HOST}")
        print(f"Database: {RDS_DB}")
        print(f"User: {RDS_USER}")
        print("-" * 50)
        
        # Connect to database
        connection = psycopg2.connect(
            host=RDS_HOST,
            user=RDS_USER,
            password=RDS_PASSWORD,
            port=RDS_PORT,
            database=RDS_DB
        )
        
        cursor = connection.cursor()
        
        # Test 1: Basic connection test
        print("✅ Database connection successful!")
        
        # Test 2: Check database version
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        print(f"📊 PostgreSQL Version: {version.split(',')[0]}")
        
        # Test 3: Check current time
        cursor.execute("SELECT NOW();")
        current_time = cursor.fetchone()[0]
        print(f"🕒 Database Time: {current_time}")
        
        # Test 4: List all databases
        cursor.execute("SELECT datname FROM pg_database WHERE datistemplate = false ORDER BY datname;")
        databases = cursor.fetchall()
        print(f"🗄️ Available Databases:")
        for db in databases:
            print(f"   - {db[0]}")
        
        # Test 5: Check if our application tables exist
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
            ORDER BY table_name;
        """)
        tables = cursor.fetchall()
        
        if tables:
            print(f"\n📋 Existing Tables in '{RDS_DB}' database:")
            for table in tables:
                print(f"   - {table[0]}")
                
                # Get row count for each table
                try:
                    cursor.execute(f"SELECT COUNT(*) FROM {table[0]};")
                    count = cursor.fetchone()[0]
                    print(f"     Rows: {count}")
                except Exception as e:
                    print(f"     Error counting rows: {e}")
        else:
            print(f"\n📋 No application tables found in '{RDS_DB}' database")
            print("   This is expected if using the default postgres database")
        
        # Test 6: Check if crmportal database exists
        cursor.execute("SELECT 1 FROM pg_database WHERE datname='crmportal';")
        crmportal_exists = cursor.fetchone()
        
        if crmportal_exists:
            print(f"\n🎯 'crmportal' database exists!")
            
            # Connect to crmportal database to check its contents
            try:
                crm_connection = psycopg2.connect(
                    host=RDS_HOST,
                    user=RDS_USER,
                    password=RDS_PASSWORD,
                    port=RDS_PORT,
                    database='crmportal'
                )
                crm_cursor = crm_connection.cursor()
                
                # Check tables in crmportal
                crm_cursor.execute("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_type = 'BASE TABLE'
                    ORDER BY table_name;
                """)
                crm_tables = crm_cursor.fetchall()
                
                if crm_tables:
                    print(f"📋 Tables in 'crmportal' database:")
                    for table in crm_tables:
                        print(f"   - {table[0]}")
                        
                        # Get row count for each table
                        try:
                            crm_cursor.execute(f"SELECT COUNT(*) FROM {table[0]};")
                            count = crm_cursor.fetchone()[0]
                            print(f"     Rows: {count}")
                            
                            # Show sample data if table has data
                            if count > 0:
                                crm_cursor.execute(f"SELECT * FROM {table[0]} LIMIT 3;")
                                samples = crm_cursor.fetchall()
                                print(f"     Sample data: {samples[:1]}...")  # Show first row
                        except Exception as e:
                            print(f"     Error: {e}")
                else:
                    print(f"📋 No tables found in 'crmportal' database")
                
                crm_cursor.close()
                crm_connection.close()
                
            except Exception as e:
                print(f"❌ Error connecting to crmportal database: {e}")
        else:
            print(f"\n📋 'crmportal' database does not exist")
        
        # Test 7: Test a simple query
        cursor.execute("SELECT 'Database test successful!' as message, CURRENT_TIMESTAMP as timestamp;")
        result = cursor.fetchone()
        print(f"\n🧪 Test Query Result:")
        print(f"   Message: {result[0]}")
        print(f"   Timestamp: {result[1]}")
        
        cursor.close()
        connection.close()
        
        print(f"\n🎉 All database tests completed successfully!")
        print(f"🔗 Connection URL: postgresql://{RDS_USER}:***@{RDS_HOST}:{RDS_PORT}/{RDS_DB}")
        
        return True
        
    except Exception as e:
        print(f"❌ Database connection error: {str(e)}")
        return False

def test_web_health():
    """Test the web application health endpoint"""
    try:
        import requests
        
        print(f"\n🌐 Testing Web Application Health...")
        url = "https://gaadimech-crm-prod.eba-ftgmu9fp.ap-south-1.elasticbeanstalk.com/health"
        
        response = requests.get(url, timeout=10)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {data}")
            print("✅ Web application health check passed!")
        else:
            print(f"❌ Health check failed with status {response.status_code}")
            
    except ImportError:
        print("📝 Skipping web test (requests module not available)")
    except Exception as e:
        print(f"❌ Web health test error: {e}")

if __name__ == "__main__":
    print("🗄️ GaadiMech CRM - Database Connection Test")
    print("=" * 60)
    print(f"Test Date: {datetime.now()}")
    print("=" * 60)
    
    # Test database connection
    db_success = test_connection()
    
    # Test web application
    test_web_health()
    
    print("=" * 60)
    if db_success:
        print("🎉 Overall Status: SUCCESS")
    else:
        print("❌ Overall Status: FAILED") 