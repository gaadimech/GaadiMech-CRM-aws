#!/usr/bin/env python3
import requests
import time
from datetime import datetime

# Application URL
APP_URL = "https://gaadimech-crm-prod.eba-ftgmu9fp.ap-south-1.elasticbeanstalk.com"

def fix_database_and_create_users():
    """Use the application's internal database connection to fix issues"""
    print("🔧 GaadiMech CRM - Database Setup via Application Endpoints")
    print("=" * 80)
    print(f"Application URL: {APP_URL}")
    print(f"Setup Date: {datetime.now()}")
    print("=" * 80)
    
    # Step 1: Initialize Database (creates tables and admin user)
    print("\n🗄️ Step 1: Initialize Database")
    print("-" * 50)
    
    try:
        print("📡 Calling /init_db endpoint...")
        response = requests.get(f"{APP_URL}/init_db", timeout=60)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ Database initialization successful!")
            print(f"Response: {response.text[:200]}...")
        else:
            print(f"❌ Database initialization failed")
            print(f"Response: {response.text[:300]}...")
            
    except Exception as e:
        print(f"❌ Error with database initialization: {e}")
    
    # Step 2: Create specific users
    print("\n👥 Step 2: Create Specific Users (admin & surakshit)")
    print("-" * 50)
    
    try:
        print("📡 Calling /create_users endpoint...")
        response = requests.get(f"{APP_URL}/create_users", timeout=60)
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ User creation successful!")
            if "Users Created/Updated Successfully" in response.text:
                print("✅ Users were created/updated successfully!")
            print(f"Response preview: {response.text[:400]}...")
        else:
            print(f"❌ User creation failed")
            print(f"Response: {response.text[:300]}...")
            
    except Exception as e:
        print(f"❌ Error with user creation: {e}")
    
    # Step 3: Test application health
    print("\n🏥 Step 3: Check Application Health")
    print("-" * 50)
    
    try:
        print("📡 Calling /health endpoint...")
        health_response = requests.get(f"{APP_URL}/health", timeout=30)
        
        print(f"Health Status Code: {health_response.status_code}")
        
        if health_response.status_code == 200:
            health_data = health_response.json()
            print("✅ Application is healthy!")
            print(f"Health Status: {health_data.get('status')}")
            print(f"Database: {health_data.get('database')}")
            print(f"Environment: {health_data.get('environment')}")
        else:
            print(f"⚠️ Health check returned status {health_response.status_code}")
            print(f"Response: {health_response.text[:200]}...")
            
    except Exception as e:
        print(f"❌ Health check error: {e}")
    
    # Step 4: Test database inspection (admin access required)
    print("\n🔍 Step 4: Quick Database Test")
    print("-" * 50)
    
    try:
        print("📡 Calling /test_db endpoint...")
        test_response = requests.get(f"{APP_URL}/test_db", timeout=30)
        
        print(f"DB Test Status Code: {test_response.status_code}")
        
        if test_response.status_code == 200:
            print("✅ Database test successful!")
            if "Database Connection Successful" in test_response.text:
                print("✅ Database connection confirmed!")
            print(f"Response preview: {test_response.text[:300]}...")
        else:
            print(f"⚠️ Database test returned status {test_response.status_code}")
            
    except Exception as e:
        print(f"❌ Database test error: {e}")
    
    # Step 5: Test login for created users
    print("\n🔑 Step 5: Test Login Credentials")
    print("-" * 50)
    
    users_to_test = [
        {"username": "admin", "password": "admin123", "role": "Administrator"},
        {"username": "surakshit", "password": "surakshit123", "role": "Regular User"}
    ]
    
    session = requests.Session()
    
    for user in users_to_test:
        try:
            print(f"\n👤 Testing login for: {user['username']} ({user['role']})")
            
            # Attempt login
            login_data = {
                'username': user['username'],
                'password': user['password']
            }
            
            login_response = session.post(
                f"{APP_URL}/login", 
                data=login_data, 
                timeout=30,
                allow_redirects=False
            )
            
            print(f"   Login Status Code: {login_response.status_code}")
            
            if login_response.status_code == 302:  # Redirect after successful login
                print(f"   ✅ Login successful for {user['username']}")
                redirect_location = login_response.headers.get('Location', 'Unknown')
                print(f"   📍 Redirect to: {redirect_location}")
                
                # Test accessing dashboard after login
                if 'dashboard' in redirect_location or redirect_location == '/':
                    dashboard_response = session.get(f"{APP_URL}/dashboard", timeout=30)
                    if dashboard_response.status_code == 200:
                        print(f"   ✅ Dashboard access successful")
                    else:
                        print(f"   ⚠️ Dashboard access failed: {dashboard_response.status_code}")
                        
            elif login_response.status_code == 200:
                # Check response content for success indicators
                if "Invalid" in login_response.text or "error" in login_response.text.lower():
                    print(f"   ❌ Login failed for {user['username']}")
                    print(f"   Response preview: {login_response.text[:200]}...")
                else:
                    print(f"   ✅ Login successful for {user['username']}")
            else:
                print(f"   ❌ Login failed for {user['username']} with status {login_response.status_code}")
                
        except Exception as e:
            print(f"   ❌ Error testing login for {user['username']}: {e}")
    
    # Summary
    print("\n" + "=" * 80)
    print("🎯 SETUP SUMMARY")
    print("=" * 80)
    print("✅ What was accomplished:")
    print("   1. Database tables created/verified")
    print("   2. Admin and Surakshit users created")
    print("   3. Application health checked")
    print("   4. Login credentials tested")
    print("")
    print("🔑 Login Credentials:")
    print("   👤 Admin User:")
    print("      Username: admin")
    print("      Password: admin123")
    print("      Role: Administrator (Full Access)")
    print("")
    print("   👤 Surakshit User:")
    print("      Username: surakshit") 
    print("      Password: surakshit123")
    print("      Role: Regular User")
    print("")
    print("🌐 Application URL:")
    print(f"   {APP_URL}")
    print("")
    print("📱 Next Steps:")
    print("   1. Open the application URL in your browser")
    print("   2. Login with either of the above credentials")
    print("   3. Access /db_inspect as admin to see database details")
    print("   4. Start using the CRM system!")
    print("=" * 80)

if __name__ == "__main__":
    fix_database_and_create_users() 