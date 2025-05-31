#!/usr/bin/env python3
import psycopg2
from datetime import datetime
import hashlib

# RDS connection details
RDS_HOST = "gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com"
RDS_USER = "postgres"
RDS_PASSWORD = "GaadiMech2024!"
RDS_PORT = 5432
RDS_DB = "crmportal"

def hash_password(password):
    """Create a simple password hash (Note: Use werkzeug in production)"""
    return hashlib.sha256(password.encode()).hexdigest()

def create_users_directly():
    """Create users directly in the crmportal database"""
    print("🔧 Creating Users Directly in RDS Database")
    print("=" * 60)
    
    try:
        # Connect to the crmportal database
        print("🔗 Connecting to crmportal database...")
        connection = psycopg2.connect(
            host=RDS_HOST,
            user=RDS_USER,
            password=RDS_PASSWORD,
            port=RDS_PORT,
            database=RDS_DB
        )
        
        cursor = connection.cursor()
        
        # Create users table if it doesn't exist
        print("📋 Creating users table...")
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            username VARCHAR(80) UNIQUE NOT NULL,
            name VARCHAR(100) NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            is_admin BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """
        cursor.execute(create_table_sql)
        
        # Insert admin user
        print("👑 Creating admin user...")
        admin_password_hash = hash_password("admin123")
        
        # Check if admin exists
        cursor.execute("SELECT id FROM users WHERE username = %s", ("admin",))
        if cursor.fetchone() is None:
            cursor.execute("""
                INSERT INTO users (username, name, password_hash, is_admin)
                VALUES (%s, %s, %s, %s)
            """, ("admin", "Administrator", admin_password_hash, True))
            print("✅ Admin user created successfully!")
        else:
            print("ℹ️ Admin user already exists")
        
        # Insert surakshit user
        print("👤 Creating surakshit user...")
        surakshit_password_hash = hash_password("surakshit123")
        
        # Check if surakshit exists
        cursor.execute("SELECT id FROM users WHERE username = %s", ("surakshit",))
        if cursor.fetchone() is None:
            cursor.execute("""
                INSERT INTO users (username, name, password_hash, is_admin)
                VALUES (%s, %s, %s, %s)
            """, ("surakshit", "Surakshit Soni", surakshit_password_hash, False))
            print("✅ Surakshit user created successfully!")
        else:
            print("ℹ️ Surakshit user already exists")
        
        # Commit changes
        connection.commit()
        
        # Verify users created
        print("\n📊 Verifying users in database...")
        cursor.execute("SELECT id, username, name, is_admin, created_at FROM users ORDER BY id")
        users = cursor.fetchall()
        
        print(f"Total users found: {len(users)}")
        print("-" * 80)
        print(f"{'ID':<5} {'Username':<15} {'Name':<20} {'Admin':<10} {'Created'}")
        print("-" * 80)
        
        for user in users:
            user_id, username, name, is_admin, created_at = user
            admin_status = "Yes" if is_admin else "No"
            print(f"{user_id:<5} {username:<15} {name:<20} {admin_status:<10} {created_at}")
        
        print("\n🎉 User creation completed successfully!")
        print("\n📋 Login Credentials:")
        print("1. Username: admin     | Password: admin123     (Administrator)")
        print("2. Username: surakshit | Password: surakshit123 (Regular User)")
        
    except psycopg2.Error as e:
        print(f"❌ Database error: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False
    finally:
        if 'connection' in locals():
            cursor.close()
            connection.close()
            print("\n🔐 Database connection closed.")
    
    return True

if __name__ == "__main__":
    success = create_users_directly()
    if success:
        print("\n✅ All operations completed successfully!")
    else:
        print("\n❌ Some operations failed. Check the logs above.") 