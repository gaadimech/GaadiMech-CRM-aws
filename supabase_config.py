"""
Supabase Database Configuration Helper
=====================================

This file contains helper functions and configurations for connecting to Supabase.
"""

import os
from sqlalchemy import create_engine
from sqlalchemy.pool import NullPool

def get_supabase_url():
    """
    Get the Supabase database URL from environment variables.
    
    Returns:
        str: The properly formatted database URL
    """
    # Try to get full DATABASE_URL first
    database_url = os.getenv("DATABASE_URL")
    
    if database_url:
        # Ensure we're using postgresql:// format
        if database_url.startswith("postgres://"):
            database_url = database_url.replace("postgres://", "postgresql://", 1)
        return database_url
    
    # Build from individual components
    supabase_host = os.getenv("SUPABASE_HOST", "aws-0-ap-south-1.pooler.supabase.com")
    supabase_db = os.getenv("SUPABASE_DB", "postgres")
    supabase_user = os.getenv("SUPABASE_USER")
    supabase_password = os.getenv("SUPABASE_PASSWORD")
    supabase_port = os.getenv("SUPABASE_PORT", "6543")
    
    if not supabase_user or not supabase_password:
        raise ValueError("SUPABASE_USER and SUPABASE_PASSWORD must be set in environment variables")
    
    return f"postgresql://{supabase_user}:{supabase_password}@{supabase_host}:{supabase_port}/{supabase_db}"

def get_engine_config():
    """
    Get optimized SQLAlchemy engine configuration for Supabase.
    
    Returns:
        dict: Engine configuration options
    """
    return {
        'pool_size': 10,
        'pool_recycle': 300,
        'pool_pre_ping': True,
        'connect_args': {
            'sslmode': 'require',
            'connect_timeout': 10,
            'application_name': 'GaadiMech_CRM'
        }
    }

def test_connection():
    """
    Test the database connection to Supabase.
    
    Returns:
        bool: True if connection is successful, False otherwise
    """
    try:
        database_url = get_supabase_url()
        engine = create_engine(database_url, **get_engine_config())
        
        with engine.connect() as connection:
            result = connection.execute("SELECT 1")
            return True
    except Exception as e:
        print(f"Database connection failed: {e}")
        return False

def get_current_config():
    """
    Get current database configuration for debugging.
    
    Returns:
        dict: Current configuration settings
    """
    try:
        database_url = get_supabase_url()
        # Mask password for security
        masked_url = database_url
        if '@' in masked_url:
            parts = masked_url.split('@')
            if ':' in parts[0]:
                user_pass = parts[0].split('://')[-1]
                if ':' in user_pass:
                    user, password = user_pass.split(':', 1)
                    masked_url = masked_url.replace(f':{password}@', ':****@')
        
        return {
            'database_url': masked_url,
            'host': os.getenv("SUPABASE_HOST", "aws-0-ap-south-1.pooler.supabase.com"),
            'port': os.getenv("SUPABASE_PORT", "6543"),
            'database': os.getenv("SUPABASE_DB", "postgres"),
            'user': os.getenv("SUPABASE_USER", "Not set"),
            'password_set': bool(os.getenv("SUPABASE_PASSWORD"))
        }
    except Exception as e:
        return {'error': str(e)}

# Environment variables template (copy to .env file)
ENV_TEMPLATE = """
# Copy these to your .env file and update with your actual Supabase credentials

# Flask Configuration
SECRET_KEY=your_secret_key_here

# Supabase Database Configuration
# Method 1: Full connection string (recommended)
DATABASE_URL=postgresql://postgres.[your-project-ref]:[your-password]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres

# Method 2: Individual components (alternative)
SUPABASE_HOST=aws-0-ap-south-1.pooler.supabase.com
SUPABASE_DB=postgres
SUPABASE_USER=postgres.[your-project-ref]
SUPABASE_PASSWORD=your_database_password
SUPABASE_PORT=6543

# Other settings
ALLOW_DB_INIT=False
FLASK_ENV=production

# How to get your Supabase credentials:
# 1. Go to https://supabase.com/dashboard
# 2. Select your project
# 3. Go to Settings > Database
# 4. Find "Connection string" section
# 5. Copy the URI and replace DATABASE_URL above
# 6. Make sure to use your actual password, not [YOUR-PASSWORD]
"""

if __name__ == "__main__":
    # Test script
    print("Supabase Configuration Test")
    print("=" * 40)
    
    config = get_current_config()
    if 'error' in config:
        print(f"Configuration Error: {config['error']}")
        print("\nEnvironment Variables Template:")
        print(ENV_TEMPLATE)
    else:
        print("Current Configuration:")
        for key, value in config.items():
            print(f"  {key}: {value}")
        
        print("\nTesting connection...")
        if test_connection():
            print("✅ Database connection successful!")
        else:
            print("❌ Database connection failed!")
            print("\nCheck your environment variables and network connection.") 