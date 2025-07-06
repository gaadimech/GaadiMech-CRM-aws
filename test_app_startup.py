#!/usr/bin/env python3
"""
Test script to verify application startup and database connection
"""
import os
import sys
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_imports():
    """Test if all required imports work"""
    print("Testing imports...")
    try:
        from flask import Flask
        from flask_sqlalchemy import SQLAlchemy
        from flask_login import LoginManager
        from sqlalchemy import text
        print("✅ All imports successful")
        return True
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False

def test_database_connection():
    """Test database connection"""
    print("Testing database connection...")
    try:
        from flask import Flask
        from flask_sqlalchemy import SQLAlchemy
        from sqlalchemy import text
        
        app = Flask(__name__)
        DATABASE_URL = os.getenv("DATABASE_URL")
        
        if not DATABASE_URL:
            print("❌ No DATABASE_URL found in environment")
            return False
            
        app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
        app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
        
        db = SQLAlchemy(app)
        
        with app.app_context():
            result = db.session.execute(text('SELECT 1')).scalar()
            print(f"✅ Database connection successful, result: {result}")
            return True
            
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False

def test_application_startup():
    """Test if the application can start without errors"""
    print("Testing application startup...")
    try:
        # Import the application
        from application import application, db
        from sqlalchemy import text
        
        with application.app_context():
            # Test basic functionality
            result = db.session.execute(text('SELECT 1')).scalar()
            print(f"✅ Application startup successful, DB test: {result}")
            return True
            
    except Exception as e:
        print(f"❌ Application startup failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run all tests"""
    print("Starting application tests...\n")
    
    tests = [
        ("Imports", test_imports),
        ("Database Connection", test_database_connection),
        ("Application Startup", test_application_startup)
    ]
    
    results = []
    for test_name, test_func in tests:
        print(f"\n--- {test_name} ---")
        result = test_func()
        results.append((test_name, result))
    
    print("\n" + "="*50)
    print("TEST RESULTS:")
    print("="*50)
    
    all_passed = True
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name}: {status}")
        if not result:
            all_passed = False
    
    if all_passed:
        print("\n🎉 All tests passed! Application should work correctly.")
    else:
        print("\n⚠️  Some tests failed. Check the errors above.")
    
    return all_passed

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 