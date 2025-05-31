#!/usr/bin/env python3
import requests
import json
from datetime import datetime

# Application URL
APP_URL = "https://gaadimech-crm-prod.eba-ftgmu9fp.ap-south-1.elasticbeanstalk.com"

def test_user_creation():
    """Test the user creation endpoint"""
    print("🔧 Testing User Creation Endpoint")
    print("=" * 50)
    
    try:
        # Test the user creation endpoint
        print("📡 Calling /create_users endpoint...")
        response = requests.get(f"{APP_URL}/create_users", timeout=30)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ User creation endpoint successful!")
            print("\n📋 Response Preview:")
            # Print first 500 characters of the response
            content = response.text
            if "Users Created/Updated Successfully" in content:
                print("✅ Users were created/updated successfully!")
            else:
                print("⚠️ Unexpected response content")
            print(content[:500] + "..." if len(content) > 500 else content)
        else:
            print(f"❌ User creation failed with status {response.status_code}")
            print(f"Response: {response.text[:300]}...")
            
    except Exception as e:
        print(f"❌ Error testing user creation: {e}")

def test_login_credentials():
    """Test the login credentials for both users"""
    print("\n🔑 Testing Login Credentials")
    print("=" * 50)
    
    users_to_test = [
        {"username": "admin", "password": "admin123", "role": "Administrator"},
        {"username": "surakshit", "password": "surakshit123", "role": "Regular User"}
    ]
    
    session = requests.Session()
    
    for user in users_to_test:
        try:
            print(f"\n👤 Testing login for: {user['username']} ({user['role']})")
            
            # First get the login page to get any CSRF tokens if needed
            login_page = session.get(f"{APP_URL}/login", timeout=10)
            
            # Attempt login
            login_data = {
                'username': user['username'],
                'password': user['password']
            }
            
            login_response = session.post(
                f"{APP_URL}/login", 
                data=login_data, 
                timeout=10,
                allow_redirects=False
            )
            
            print(f"   Login Status Code: {login_response.status_code}")
            
            if login_response.status_code == 302:  # Redirect after successful login
                print(f"   ✅ Login successful for {user['username']}")
                print(f"   Redirect Location: {login_response.headers.get('Location', 'Unknown')}")
            elif login_response.status_code == 200:
                # Check if login was successful by looking for success indicators
                if "dashboard" in login_response.text.lower() or "logout" in login_response.text.lower():
                    print(f"   ✅ Login successful for {user['username']}")
                else:
                    print(f"   ❌ Login failed for {user['username']}")
                    print(f"   Response preview: {login_response.text[:200]}...")
            else:
                print(f"   ❌ Login failed for {user['username']} with status {login_response.status_code}")
                
        except Exception as e:
            print(f"   ❌ Error testing login for {user['username']}: {e}")

def test_application_health():
    """Test the application health"""
    print("\n🏥 Testing Application Health")
    print("=" * 50)
    
    try:
        health_response = requests.get(f"{APP_URL}/health", timeout=10)
        print(f"Health Status Code: {health_response.status_code}")
        
        if health_response.status_code == 200:
            health_data = health_response.json()
            print("✅ Application is healthy!")
            print(f"Response: {health_data}")
        else:
            print(f"⚠️ Health check returned status {health_response.status_code}")
            
    except Exception as e:
        print(f"❌ Health check error: {e}")

if __name__ == "__main__":
    print("🚀 GaadiMech CRM - User Creation & Login Test")
    print("=" * 60)
    print(f"Application URL: {APP_URL}")
    print(f"Test Date: {datetime.now()}")
    print("=" * 60)
    
    # Test user creation
    test_user_creation()
    
    # Test application health
    test_application_health()
    
    # Test login credentials
    test_login_credentials()
    
    print("\n" + "=" * 60)
    print("🎯 Summary:")
    print("1. Visit the /create_users endpoint to create users")
    print("2. Then login with the credentials:")
    print("   👤 Username: admin, Password: admin123 (Administrator)")
    print("   👤 Username: surakshit, Password: surakshit123 (Regular User)")
    print("=" * 60) 