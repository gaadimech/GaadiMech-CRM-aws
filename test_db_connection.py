from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
import os
from dotenv import load_dotenv

load_dotenv()

def test_db_connection():
    app = Flask(__name__)
    
    # AWS RDS configuration
    RDS_HOST = os.getenv("RDS_HOST", "crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
    RDS_DB = os.getenv("RDS_DB", "crmportal")
    RDS_USER = os.getenv("RDS_USER", "crmadmin")
    RDS_PASSWORD = os.getenv("RDS_PASSWORD", "GaadiMech2024!")
    RDS_PORT = os.getenv("RDS_PORT", "5432")
    
    DATABASE_URL = f"postgresql+psycopg2://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"
    
    app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    db = SQLAlchemy(app)
    
    try:
        # Test the connection
        with app.app_context():
            result = db.session.execute(text('SELECT 1')).scalar()
            print("✅ Database connection successful!")
            
            # Test if tables exist and show user count
            tables = db.session.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                AND table_name != 'users'  -- Exclude the unused 'users' table
            """)).fetchall()
            
            print("\nExisting tables:")
            for table in tables:
                print(f"- {table[0]}")
            
            # Count users from the correct table
            user_count = db.session.execute(text("SELECT COUNT(*) FROM public.user")).scalar()
            print(f"\nTotal users in database: {user_count}")
            
            # List all users from the correct table
            users = db.session.execute(text("SELECT username, name FROM public.user ORDER BY name")).fetchall()
            print("\nUsers in database:")
            for user in users:
                print(f"- {user[1]} (username: {user[0]})")
                
    except Exception as e:
        print(f"❌ Database connection failed: {str(e)}")
        return False
    
    return True

if __name__ == "__main__":
    test_db_connection() 