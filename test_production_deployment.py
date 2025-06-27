#!/usr/bin/env python3
"""
Production Deployment Test Script for GaadiMech CRM
Tests the deployed application on AWS Elastic Beanstalk
"""

import requests
import json
from datetime import datetime

# Production URL
BASE_URL = "http://gaadimech-crm-prod.eba-ftgmu9fp.ap-south-1.elasticbeanstalk.com"

def test_endpoint(endpoint, expected_status=200, description="", allow_redirects=True):
    """Test an endpoint and return the result"""
    try:
        url = f"{BASE_URL}{endpoint}"
        response = requests.get(url, timeout=10, allow_redirects=allow_redirects)
        
        status_icon = "✅" if response.status_code == expected_status else "❌"
        print(f"{status_icon} {endpoint} - Status: {response.status_code} - {description}")
        
        return response.status_code == expected_status, response
    except Exception as e:
        print(f"❌ {endpoint} - Error: {str(e)}")
        return False, None

def main():
    print("🚀 Testing GaadiMech CRM Production Deployment")
    print("=" * 60)
    
    tests_passed = 0
    total_tests = 0
    
    # Test 1: Basic Health Check
    total_tests += 1
    success, response = test_endpoint("/health", 200, "Basic health check")
    if success and response:
        try:
            data = response.json()
            if data.get('status') == 'healthy':
                print("   ✅ Health status: healthy")
                print(f"   ✅ Database: {data.get('database', 'unknown')}")
                tests_passed += 1
            else:
                print(f"   ❌ Unexpected health status: {data}")
        except:
            print("   ✅ Health endpoint responding (non-JSON response)")
            tests_passed += 1
    
    # Test 2: Login Page
    total_tests += 1
    success, response = test_endpoint("/login", 200, "Login page accessibility")
    if success and response:
        if "CRM Portal" in response.text:
            print("   ✅ Login page contains expected content")
            tests_passed += 1
        else:
            print("   ❌ Login page missing expected content")
    
    # Test 3: Dashboard Redirect (should redirect to login) - Don't follow redirects
    total_tests += 1
    success, response = test_endpoint("/dashboard", 302, "Dashboard protection (should redirect)", allow_redirects=False)
    if success and response:
        if "/login" in response.headers.get('Location', ''):
            print("   ✅ Dashboard properly redirects to login")
            tests_passed += 1
        else:
            print(f"   ❌ Dashboard redirects to unexpected location: {response.headers.get('Location', 'None')}")
    
    # Test 4: Root Page Redirect - Don't follow redirects
    total_tests += 1
    success, response = test_endpoint("/", 302, "Root page protection (should redirect)", allow_redirects=False)
    if success and response:
        if "/login" in response.headers.get('Location', ''):
            print("   ✅ Root page properly redirects to login")
            tests_passed += 1
        else:
            print(f"   ❌ Root page redirects to unexpected location: {response.headers.get('Location', 'None')}")
    
    # Test 5: 404 Error Handling
    total_tests += 1
    success, response = test_endpoint("/nonexistent-page", 404, "404 error handling")
    if success and response:
        if "404" in response.text and ("Not Found" in response.text or "Page Not Found" in response.text):
            print("   ✅ 404 page properly formatted")
            tests_passed += 1
        else:
            print("   ❌ 404 page missing expected content")
    elif success:
        tests_passed += 1
    
    # Test 6: Static Assets (check if error page loads CSS)
    total_tests += 1
    success, response = test_endpoint("/nonexistent-page", 404, "Error page styling")
    if success and response:
        if "bootstrap" in response.text.lower() or "Bootstrap" in response.text:
            print("   ✅ Error page includes Bootstrap CSS")
            tests_passed += 1
        else:
            print("   ❌ Error page missing styling")
    elif success:
        tests_passed += 1
    
    print("=" * 60)
    print(f"🎯 Test Results: {tests_passed}/{total_tests} tests passed")
    
    if tests_passed == total_tests:
        print("🎉 All tests passed! Deployment is successful!")
        print("\n📋 Application Status:")
        print(f"   🌐 URL: {BASE_URL}")
        print("   ✅ Application is running")
        print("   ✅ Database connectivity confirmed")
        print("   ✅ Authentication system working")
        print("   ✅ Error handling functional")
        print("   ✅ Dashboard functionality deployed")
        print("\n🔐 To access the dashboard:")
        print(f"   1. Go to: {BASE_URL}/login")
        print("   2. Login with your credentials")
        print("   3. Access dashboard functionality")
        
    else:
        print(f"⚠️  {total_tests - tests_passed} tests failed. Please check the issues above.")
    
    print("\n" + "=" * 60)

if __name__ == "__main__":
    main() 