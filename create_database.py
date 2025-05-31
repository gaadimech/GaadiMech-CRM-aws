#!/usr/bin/env python3
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

# RDS connection details
RDS_HOST = "gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com"
RDS_USER = "postgres"
RDS_PASSWORD = "GaadiMech2024!"
RDS_PORT = 5432

def create_database():
    try:
        # Connect to the default postgres database
        print("🔗 Connecting to PostgreSQL server...")
        connection = psycopg2.connect(
            host=RDS_HOST,
            user=RDS_USER,
            password=RDS_PASSWORD,
            port=RDS_PORT,
            database='postgres'
        )
        
        # Set autocommit mode for database creation
        connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = connection.cursor()
        
        # Check if crmportal database exists
        print("🔍 Checking if 'crmportal' database exists...")
        cursor.execute("SELECT 1 FROM pg_database WHERE datname='crmportal'")
        exists = cursor.fetchone()
        
        if exists:
            print("✅ Database 'crmportal' already exists!")
        else:
            print("🚀 Creating 'crmportal' database...")
            cursor.execute("CREATE DATABASE crmportal")
            print("✅ Database 'crmportal' created successfully!")
        
        # Test connection to the new database
        print("🧪 Testing connection to 'crmportal' database...")
        test_connection = psycopg2.connect(
            host=RDS_HOST,
            user=RDS_USER,
            password=RDS_PASSWORD,
            port=RDS_PORT,
            database='crmportal'
        )
        test_connection.close()
        print("✅ Connection to 'crmportal' database successful!")
        
        cursor.close()
        connection.close()
        
        print("\n🎉 Database setup completed successfully!")
        print(f"📝 Database URL: postgresql://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/crmportal")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False

if __name__ == "__main__":
    print("🗄️ GaadiMech CRM - Database Setup")
    print("=" * 40)
    create_database() 