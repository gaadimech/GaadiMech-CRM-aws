"""
Cache Manager for Dashboard Performance Optimization
Handles caching of frequently accessed dashboard data to reduce database load
"""

import json
import hashlib
from datetime import datetime, timedelta
from flask import current_app
from flask_caching import Cache
import pickle

class DashboardCacheManager:
    def __init__(self, app=None):
        self.cache = None
        if app:
            self.init_app(app)
    
    def init_app(self, app):
        """Initialize cache with app configuration"""
        # Configure cache based on environment
        if app.config.get('REDIS_URL'):
            cache_config = {
                'CACHE_TYPE': 'redis',
                'CACHE_REDIS_URL': app.config['REDIS_URL'],
                'CACHE_DEFAULT_TIMEOUT': 300  # 5 minutes default
            }
        else:
            # Fallback to simple cache for development
            cache_config = {
                'CACHE_TYPE': 'simple',
                'CACHE_DEFAULT_TIMEOUT': 300
            }
        
        app.config.update(cache_config)
        self.cache = Cache(app)
    
    def get_cache_key(self, prefix, **kwargs):
        """Generate a consistent cache key"""
        key_data = f"{prefix}:{':'.join(f'{k}={v}' for k, v in sorted(kwargs.items()))}"
        return hashlib.md5(key_data.encode()).hexdigest()[:16]
    
    def cache_dashboard_data(self, user_id, selected_date, selected_user_id, data, timeout=300):
        """Cache dashboard data with 5-minute default timeout"""
        cache_key = self.get_cache_key(
            'dashboard',
            user_id=user_id,
            date=selected_date,
            selected_user=selected_user_id or 'all'
        )
        
        # Convert complex objects to serializable format
        serializable_data = self._serialize_dashboard_data(data)
        
        self.cache.set(cache_key, serializable_data, timeout=timeout)
        return cache_key
    
    def get_cached_dashboard_data(self, user_id, selected_date, selected_user_id):
        """Retrieve cached dashboard data"""
        cache_key = self.get_cache_key(
            'dashboard',
            user_id=user_id,
            date=selected_date,
            selected_user=selected_user_id or 'all'
        )
        
        cached_data = self.cache.get(cache_key)
        if cached_data:
            return self._deserialize_dashboard_data(cached_data)
        return None
    
    def cache_user_performance(self, user_id, date, performance_data, timeout=600):
        """Cache user performance data with 10-minute timeout"""
        cache_key = self.get_cache_key('user_performance', user_id=user_id, date=date)
        self.cache.set(cache_key, performance_data, timeout=timeout)
    
    def get_cached_user_performance(self, user_id, date):
        """Get cached user performance data"""
        cache_key = self.get_cache_key('user_performance', user_id=user_id, date=date)
        return self.cache.get(cache_key)
    
    def cache_status_counts(self, user_id, status_counts, timeout=300):
        """Cache status counts for a user"""
        cache_key = self.get_cache_key('status_counts', user_id=user_id)
        self.cache.set(cache_key, status_counts, timeout=timeout)
    
    def get_cached_status_counts(self, user_id):
        """Get cached status counts"""
        cache_key = self.get_cache_key('status_counts', user_id=user_id)
        return self.cache.get(cache_key)
    
    def invalidate_user_cache(self, user_id):
        """Invalidate all cache entries for a specific user"""
        # Note: This is a simple implementation. For production, consider using cache tags
        patterns = [
            f"dashboard:*user_id={user_id}*",
            f"user_performance:*user_id={user_id}*",
            f"status_counts:*user_id={user_id}*"
        ]
        
        try:
            # If using Redis, we can use pattern-based deletion
            if hasattr(self.cache.cache, '_write_client'):
                redis_client = self.cache.cache._write_client
                for pattern in patterns:
                    keys = redis_client.keys(pattern)
                    if keys:
                        redis_client.delete(*keys)
        except Exception as e:
            current_app.logger.warning(f"Cache invalidation failed: {e}")
            # Fallback: clear all cache
            self.cache.clear()
    
    def invalidate_date_cache(self, date):
        """Invalidate cache entries for a specific date"""
        try:
            if hasattr(self.cache.cache, '_write_client'):
                redis_client = self.cache.cache._write_client
                pattern = f"*date={date}*"
                keys = redis_client.keys(pattern)
                if keys:
                    redis_client.delete(*keys)
        except Exception as e:
            current_app.logger.warning(f"Date cache invalidation failed: {e}")
    
    def _serialize_dashboard_data(self, data):
        """Convert dashboard data to cache-friendly format"""
        serializable = {}
        
        for key, value in data.items():
            if key == 'todays_followups':
                # Convert Lead objects to dictionaries
                serializable[key] = [
                    {
                        'id': lead.id,
                        'customer_name': lead.customer_name,
                        'mobile': lead.mobile,
                        'car_registration': lead.car_registration,
                        'followup_date': lead.followup_date.isoformat() if lead.followup_date else None,
                        'remarks': lead.remarks,
                        'status': lead.status,
                        'creator_id': lead.creator_id
                    } for lead in value
                ]
            elif key == 'users':
                # Convert User objects to dictionaries
                serializable[key] = [
                    {
                        'id': user.id,
                        'username': user.username,
                        'name': user.name,
                        'is_admin': user.is_admin
                    } for user in value
                ]
            elif key == 'user_performance':
                # Handle user performance data
                serializable[key] = [
                    {
                        **perf,
                        'user': {
                            'id': perf['user'].id,
                            'username': perf['user'].username,
                            'name': perf['user'].name,
                            'is_admin': perf['user'].is_admin
                        }
                    } for perf in value
                ]
            else:
                serializable[key] = value
        
        return serializable
    
    def _deserialize_dashboard_data(self, data):
        """Convert cached data back to original format"""
        # Note: This returns dictionaries instead of ORM objects
        # The template should be updated to handle this or we need to reconstruct objects
        return data
    
    def warm_cache(self, user_ids, dates):
        """Pre-warm cache with data for specific users and dates"""
        # This can be called during off-peak hours to prepare cache
        for user_id in user_ids:
            for date in dates:
                # Trigger cache population for common queries
                pass  # Implementation depends on specific warming strategy


# Global cache manager instance
dashboard_cache = DashboardCacheManager()


def init_cache(app):
    """Initialize cache with Flask app"""
    dashboard_cache.init_app(app)
    return dashboard_cache 