import psycopg2
from psycopg2 import OperationalError
import os

# AWS RDS connection string - Replace with your actual credentials
RDS_CONNECTION_STRING = "postgresql://postgres:GaadiMech2024!@gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal"

def test_database_connection():
    try:
        print("🔗 Testing AWS RDS PostgreSQL connection...")
        print("=" * 50)
        
        # Use environment variable or fallback to RDS string
        DATABASE_URL = os.getenv("DATABASE_URL", RDS_CONNECTION_STRING)
        
        # Remove any postgres:// prefix and replace with postgresql://
        if DATABASE_URL.startswith("postgres://"):
            DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
        
        print(f"Connecting to: {DATABASE_URL[:30]}...")
        
        # Attempt connection
        connection = psycopg2.connect(DATABASE_URL)
        cursor = connection.cursor()
        
        # Test query
        cursor.execute("SELECT version();")
        db_version = cursor.fetchone()
        
        print("✅ Connection successful!")
        print(f"📊 Database version: {db_version[0]}")
        
        # Test table existence
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name;
        """)
        
        tables = cursor.fetchall()
        print(f"📋 Tables found: {len(tables)}")
        
        for table in tables:
            print(f"   - {table[0]}")
        
        cursor.close()
        connection.close()
        
        print("\n🎉 AWS RDS database test completed successfully!")
        
    except OperationalError as e:
        print(f"❌ Connection failed: {e}")
        print("\n🔧 Troubleshooting:")
        print("1. Check your RDS instance is running")
        print("2. Verify security group allows your IP")
        print("3. Confirm database credentials")
        print("4. Check if database 'crmportal' exists")
        
    except Exception as e:
        print(f"❌ Unexpected error: {e}")

if __name__ == "__main__":
    test_database_connection()