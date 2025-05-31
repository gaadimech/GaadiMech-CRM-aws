"""
Performance Testing Script for Dashboard Optimization
Run this to measure the impact of performance improvements
"""

import time
import requests
from datetime import datetime
import statistics

class DashboardPerformanceTester:
    def __init__(self, base_url="http://localhost:8080"):
        self.base_url = base_url
        self.session = requests.Session()
        
    def login(self, username, password):
        """Login to get session"""
        login_data = {
            'username': username,
            'password': password
        }
        response = self.session.post(f"{self.base_url}/login", data=login_data)
        return response.status_code == 200 or "dashboard" in response.url
    
    def measure_dashboard_load_time(self, date=None, user_id=None):
        """Measure dashboard loading time"""
        params = {}
        if date:
            params['date'] = date
        if user_id:
            params['user_id'] = user_id
        
        start_time = time.time()
        response = self.session.get(f"{self.base_url}/dashboard", params=params)
        end_time = time.time()
        
        load_time = end_time - start_time
        success = response.status_code == 200
        
        return {
            'load_time': load_time,
            'success': success,
            'status_code': response.status_code,
            'content_length': len(response.content) if success else 0
        }
    
    def run_performance_test(self, iterations=10):
        """Run multiple tests to get average performance"""
        print("🚀 Starting Dashboard Performance Test")
        print(f"Running {iterations} iterations...")
        
        load_times = []
        successful_requests = 0
        
        for i in range(iterations):
            print(f"Test {i+1}/{iterations}...", end=' ')
            
            result = self.measure_dashboard_load_time()
            
            if result['success']:
                load_times.append(result['load_time'])
                successful_requests += 1
                print(f"✅ {result['load_time']:.3f}s")
            else:
                print(f"❌ Failed (Status: {result['status_code']})")
        
        if load_times:
            avg_time = statistics.mean(load_times)
            min_time = min(load_times)
            max_time = max(load_times)
            median_time = statistics.median(load_times)
            
            print("\n" + "="*50)
            print("📊 PERFORMANCE RESULTS")
            print("="*50)
            print(f"Successful Requests: {successful_requests}/{iterations}")
            print(f"Average Load Time:   {avg_time:.3f} seconds")
            print(f"Minimum Load Time:   {min_time:.3f} seconds")
            print(f"Maximum Load Time:   {max_time:.3f} seconds")
            print(f"Median Load Time:    {median_time:.3f} seconds")
            
            # Performance rating
            if avg_time < 1.0:
                rating = "🚀 EXCELLENT"
            elif avg_time < 2.0:
                rating = "✅ GOOD"
            elif avg_time < 3.0:
                rating = "⚠️  ACCEPTABLE"
            else:
                rating = "❌ NEEDS IMPROVEMENT"
            
            print(f"Performance Rating:  {rating}")
            print("="*50)
            
            return {
                'avg_time': avg_time,
                'min_time': min_time,
                'max_time': max_time,
                'median_time': median_time,
                'success_rate': successful_requests / iterations * 100
            }
        else:
            print("\n❌ All requests failed!")
            return None
    
    def test_different_scenarios(self):
        """Test various dashboard scenarios"""
        scenarios = [
            {"name": "Today's Dashboard", "params": {}},
            {"name": "Yesterday's Dashboard", "params": {"date": "2025-02-06"}},
            {"name": "Admin View All Users", "params": {}},
        ]
        
        print("🔍 Testing Different Scenarios")
        print("="*50)
        
        results = {}
        for scenario in scenarios:
            print(f"\nTesting: {scenario['name']}")
            
            start_time = time.time()
            result = self.measure_dashboard_load_time(**scenario['params'])
            
            if result['success']:
                print(f"✅ {result['load_time']:.3f}s")
                results[scenario['name']] = result['load_time']
            else:
                print(f"❌ Failed")
                results[scenario['name']] = None
        
        return results

def main():
    """Main performance testing function"""
    print("🏁 CRM Dashboard Performance Testing")
    print("Make sure your Flask app is running on http://localhost:8080")
    print()
    
    # Get login credentials
    username = input("Enter username (or press Enter for 'admin'): ").strip() or "admin"
    password = input("Enter password: ").strip()
    
    if not password:
        print("❌ Password is required")
        return
    
    tester = DashboardPerformanceTester()
    
    # Try to login
    print("\n🔐 Logging in...")
    if tester.login(username, password):
        print("✅ Login successful!")
        
        # Run performance tests
        print("\n" + "="*50)
        results = tester.run_performance_test(iterations=5)
        
        if results:
            # Test different scenarios
            print("\n")
            scenario_results = tester.test_different_scenarios()
            
            # Summary
            print("\n" + "="*50)
            print("📋 OPTIMIZATION RECOMMENDATIONS")
            print("="*50)
            
            if results['avg_time'] > 3.0:
                print("🚨 HIGH PRIORITY:")
                print("   - Apply database indexes migration")
                print("   - Check database connection pool settings")
                print("   - Monitor slow queries")
            elif results['avg_time'] > 1.5:
                print("⚠️  MEDIUM PRIORITY:")
                print("   - Consider implementing caching")
                print("   - Optimize complex queries")
            else:
                print("✅ PERFORMANCE IS GOOD:")
                print("   - Consider adding monitoring")
                print("   - Plan for future scaling")
            
            print("\n💡 NEXT STEPS:")
            print("   1. Apply the database indexes: flask db upgrade")
            print("   2. Install Redis for caching: pip install redis")
            print("   3. Monitor query performance in production")
            print("   4. Set up performance alerts")
    
    else:
        print("❌ Login failed. Please check credentials and ensure the app is running.")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⏹️  Test interrupted by user")
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        print("Make sure your Flask app is running and accessible.") 