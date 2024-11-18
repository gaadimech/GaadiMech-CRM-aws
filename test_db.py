import psycopg2
import os
from urllib.parse import urlparse

def test_database_connection(url):
    try:
        "postgresql://postgres.qcvfmiqzkfhinxlhknnd:GaadiMech123@aws-0-ap-south-1.pooler.supabase.com:6543/postgres"
        result = urlparse(url)
        username = result.username
        password = result.password
        database = result.path[1:]
        hostname = result.hostname
        port = result.port

        # Create connection
        connection = psycopg2.connect(
            database=database,
            user=username,
            password=password,
            host=hostname,
            port=port
        )
        
        print("Database connection successful!")
        connection.close()
        return True
    except Exception as e:
        print(f"Connection error: {str(e)}")
        return False

# Test your connection string
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres.qcvfmiqzkfhinxlhknnd:GaadiMech123@aws-0-ap-south-1.pooler.supabase.com:6543/postgres")
print(f"Connecting to database: {DATABASE_URL}")
if DATABASE_URL:
    test_database_connection(DATABASE_URL)
else:
    print("No DATABASE_URL environment variable found")