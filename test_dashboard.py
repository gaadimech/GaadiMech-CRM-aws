#!/usr/bin/env python3
"""
Test script to verify dashboard functionality
"""

import sys
import os
from datetime import datetime

# Add the current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def test_dashboard_functionality():
    """Test the dashboard functionality"""
    try:
        print("🔍 Testing Dashboard Functionality...")
        
        # Import the Flask app
        import app
        from dashboard_optimized import get_optimized_dashboard_data
        
        print("✅ Successfully imported Flask app and dashboard module")
        
        # Test database connection
        with app.app.app_context():
            # Check if we can query users
            users = app.User.query.all()
            print(f"✅ Found {len(users)} users in database")
            
            # Check if we can query leads
            leads = app.Lead.query.limit(5).all()
            print(f"✅ Found {len(leads)} leads (showing first 5)")
            
            if users:
                # Test dashboard data generation with a real user
                test_user = users[0]
                selected_date = datetime.now().strftime('%Y-%m-%d')
                
                print(f"🧪 Testing dashboard data generation for user: {test_user.name}")
                
                dashboard_data = get_optimized_dashboard_data(
                    current_user=test_user,
                    selected_date=selected_date,
                    selected_user_id=str(test_user.id),
                    ist=app.ist,
                    db=app.db,
                    User=app.User,
                    Lead=app.Lead,
                    get_initial_followup_count=app.get_initial_followup_count
                )
                
                print("✅ Dashboard data generated successfully!")
                print(f"   - Today's followups: {len(dashboard_data['todays_followups'])}")
                print(f"   - Daily leads count: {dashboard_data['daily_leads_count']}")
                print(f"   - Total leads: {dashboard_data['total_leads']}")
                print(f"   - User performance entries: {len(dashboard_data['user_performance'])}")
                print(f"   - Status counts: {dashboard_data['status_counts']}")
                
            else:
                print("⚠️  No users found in database - dashboard test limited")
        
        print("\n🎉 Dashboard functionality test completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Dashboard test failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def test_web_interface():
    """Test the web interface"""
    try:
        print("\n🌐 Testing Web Interface...")
        
        import app
        app.app.config['TESTING'] = True
        
        with app.app.test_client() as client:
            # Test health check
            response = client.get('/health-check')
            if response.status_code == 200:
                print("✅ Health check endpoint working")
            else:
                print(f"❌ Health check failed: {response.status_code}")
                return False
            
            # Test login page
            response = client.get('/login')
            if response.status_code == 200:
                print("✅ Login page accessible")
            else:
                print(f"❌ Login page failed: {response.status_code}")
                return False
            
            # Test dashboard redirect (should redirect to login)
            response = client.get('/dashboard')
            if response.status_code in [302, 401]:  # Redirect to login or unauthorized
                print("✅ Dashboard properly protected (redirects to login)")
            else:
                print(f"⚠️  Dashboard response: {response.status_code}")
        
        print("✅ Web interface test completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Web interface test failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("🚀 Starting GaadiMech CRM Dashboard Tests\n")
    
    dashboard_ok = test_dashboard_functionality()
    web_ok = test_web_interface()
    
    if dashboard_ok and web_ok:
        print("\n🎉 All tests passed! Dashboard is ready for deployment.")
        sys.exit(0)
    else:
        print("\n❌ Some tests failed. Please check the issues above.")
        sys.exit(1) 