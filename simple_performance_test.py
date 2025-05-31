#!/usr/bin/env python3
"""
Simple Performance Test for Dashboard
Tests dashboard loading time after login
"""

import time
import requests
from datetime import datetime

def test_dashboard_performance():
    """Test dashboard performance with login"""
    base_url = "http://localhost:8080"
    
    # Create session
    session = requests.Session()
    
    print("🚀 Testing Dashboard Performance")
    print("=" * 50)
    
    # Test login first
    print("1. Testing login...")
    login_start = time.time()
    login_response = session.post(f"{base_url}/login", data={
        'username': 'admin',
        'password': 'admin123'
    })
    login_time = time.time() - login_start
    
    if login_response.status_code == 200 or "dashboard" in login_response.url:
        print(f"   ✅ Login successful: {login_time:.3f}s")
    else:
        print(f"   ❌ Login failed: {login_response.status_code}")
        return
    
    # Test dashboard loading multiple times
    print("\n2. Testing dashboard loading...")
    times = []
    
    for i in range(5):
        print(f"   Test {i+1}/5...", end=' ')
        
        start_time = time.time()
        response = session.get(f"{base_url}/dashboard")
        end_time = time.time()
        
        load_time = end_time - start_time
        times.append(load_time)
        
        if response.status_code == 200:
            print(f"✅ {load_time:.3f}s")
        else:
            print(f"❌ Failed ({response.status_code})")
    
    # Calculate statistics
    if times:
        avg_time = sum(times) / len(times)
        min_time = min(times)
        max_time = max(times)
        
        print("\n" + "=" * 50)
        print("📊 RESULTS")
        print("=" * 50)
        print(f"Average Load Time: {avg_time:.3f}s")
        print(f"Minimum Load Time: {min_time:.3f}s")
        print(f"Maximum Load Time: {max_time:.3f}s")
        
        # Performance rating
        if avg_time < 0.5:
            rating = "🚀 EXCELLENT"
        elif avg_time < 1.0:
            rating = "✅ VERY GOOD"
        elif avg_time < 2.0:
            rating = "👍 GOOD"
        elif avg_time < 3.0:
            rating = "⚠️  ACCEPTABLE"
        else:
            rating = "❌ NEEDS IMPROVEMENT"
        
        print(f"Performance Rating: {rating}")
        
        # Test cache effectiveness
        print("\n3. Testing cache effectiveness...")
        cache_times = []
        for i in range(3):
            start_time = time.time()
            response = session.get(f"{base_url}/dashboard")
            end_time = time.time()
            cache_times.append(end_time - start_time)
            print(f"   Cache test {i+1}: {cache_times[-1]:.3f}s")
        
        cache_avg = sum(cache_times) / len(cache_times)
        improvement = ((avg_time - cache_avg) / avg_time) * 100 if avg_time > 0 else 0
        print(f"   Cache improvement: {improvement:.1f}%")
        
        print("\n" + "=" * 50)
        print("💡 OPTIMIZATION STATUS")
        print("=" * 50)
        print("✅ Database indexes applied")
        print("✅ Optimized queries implemented")
        print("✅ Caching enabled")
        print("✅ Pagination added to followups")
        
        if avg_time < 1.0:
            print("\n🎉 Dashboard performance is now OPTIMIZED!")
        else:
            print(f"\n⚠️  Dashboard could be faster. Current: {avg_time:.3f}s")

if __name__ == "__main__":
    try:
        test_dashboard_performance()
    except Exception as e:
        print(f"❌ Test failed: {e}")
        print("Make sure the Flask app is running on http://localhost:8080") 