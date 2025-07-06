#!/usr/bin/env python3
"""
Test script to verify application routes work correctly
"""
import requests
import time

def test_route(url, expected_status=200, description=""):
    """Test a single route"""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == expected_status:
            print(f"✅ {description}: {response.status_code}")
            return True
        else:
            print(f"❌ {description}: Expected {expected_status}, got {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ {description}: Request failed - {e}")
        return False

def main():
    """Test all routes"""
    base_url = "http://127.0.0.1:5000"
    
    print("Testing application routes...\n")
    
    # Wait a moment for the server to be ready
    time.sleep(2)
    
    routes_to_test = [
        (f"{base_url}/", 302, "Root route (should redirect to login)"),
        (f"{base_url}/login", 200, "Login page"),
        (f"{base_url}/dashboard", 302, "Dashboard (should redirect to login)"),
    ]
    
    results = []
    for url, expected_status, description in routes_to_test:
        result = test_route(url, expected_status, description)
        results.append((description, result))
    
    print("\n" + "="*50)
    print("ROUTE TEST RESULTS:")
    print("="*50)
    
    all_passed = True
    for description, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{description}: {status}")
        if not result:
            all_passed = False
    
    if all_passed:
        print("\n🎉 All route tests passed! Application is working correctly.")
        print("You can now access the application at: http://127.0.0.1:5000")
    else:
        print("\n⚠️  Some route tests failed.")
    
    return all_passed

if __name__ == "__main__":
    main() 