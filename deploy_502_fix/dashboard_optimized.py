"""
Optimized Dashboard Functions for Better Performance
This file contains optimized versions of dashboard queries that reduce database hits
and improve loading times significantly.

FIXED VERSION: Now properly uses 5AM snapshot data for accurate metrics
"""

from datetime import datetime, timedelta, time
from collections import defaultdict
from sqlalchemy import func, case, and_
from flask import current_app
import pytz

def utc_to_ist(utc_dt):
    """Convert UTC datetime to IST"""
    if utc_dt is None:
        return None
    ist = pytz.timezone('Asia/Kolkata')
    if utc_dt.tzinfo is None:
        utc_dt = pytz.utc.localize(utc_dt)
    return utc_dt.astimezone(ist)

def get_optimized_dashboard_data(current_user, selected_date, selected_user_id, ist, db, User, Lead, get_initial_followup_count):
    """
    FIXED: Dashboard metrics now properly use 5AM snapshot data
    """
    try:
        # Parse the selected date
        try:
            target_date = datetime.strptime(selected_date, '%Y-%m-%d')
            target_date = ist.localize(target_date)
            next_day = target_date + timedelta(days=1)
        except ValueError:
            target_date = datetime.now(ist).replace(hour=0, minute=0, second=0, microsecond=0)
            next_day = target_date + timedelta(days=1)
            selected_date = target_date.strftime('%Y-%m-%d')
        
        # Convert to UTC for database queries
        target_date_utc = target_date.astimezone(pytz.UTC)
        next_day_utc = next_day.astimezone(pytz.UTC)
        
        # Get users based on permissions
        if current_user.is_admin:
            users = User.query.all()
        else:
            users = [current_user]
            selected_user_id = str(current_user.id)
        
        # Create user lookup for performance
        user_lookup = {user.id: user for user in users}
        
        # Base query setup with user filtering
        base_conditions = []
        if selected_user_id and current_user.is_admin:
            try:
                base_conditions.append(Lead.creator_id == int(selected_user_id))
            except ValueError:
                pass
        elif not current_user.is_admin:
            base_conditions.append(Lead.creator_id == current_user.id)
        
        # FIXED: Get the 5AM snapshot counts first
        user_ids = [user.id for user in users]
        initial_counts_by_user = get_optimized_initial_followup_counts(
            user_ids, target_date.date(), db, get_initial_followup_count
        )
        
        # QUERY 1: Get CURRENT pending followups (for display in the table)
        current_followups_query = db.session.query(Lead).filter(
            Lead.followup_date >= target_date_utc,
            Lead.followup_date < next_day_utc
        )
        if base_conditions:
            current_followups_query = current_followups_query.filter(*base_conditions)
        
        current_followups = current_followups_query.order_by(Lead.followup_date.asc()).all()
        
        # Convert followups to IST for display
        for followup in current_followups:
            if followup.followup_date:
                followup.followup_date = utc_to_ist(followup.followup_date)
            if followup.created_at:
                followup.created_at = utc_to_ist(followup.created_at)
            if followup.modified_at:
                followup.modified_at = utc_to_ist(followup.modified_at)
        
        # QUERY 2: Get daily leads count (new leads created today)
        daily_leads_count_query = db.session.query(func.count(Lead.id)).filter(
            Lead.created_at >= target_date_utc,
            Lead.created_at < next_day_utc
        )
        if base_conditions:
            daily_leads_count_query = daily_leads_count_query.filter(*base_conditions)
        
        daily_leads_count = daily_leads_count_query.scalar() or 0
        
        # QUERY 3: Get status counts in a single query
        status_counts_query = db.session.query(
            Lead.status,
            func.count(Lead.id)
        ).group_by(Lead.status)
        
        if base_conditions:
            status_counts_query = status_counts_query.filter(*base_conditions)
        
        status_counts = dict(status_counts_query.all())
        if not status_counts:
            status_counts = {'Needs Followup': 0}
        
        # QUERY 4: Get total leads count
        total_leads_query = db.session.query(func.count(Lead.id))
        if base_conditions:
            total_leads_query = total_leads_query.filter(*base_conditions)
        
        total_leads = total_leads_query.scalar() or 0
        
        # QUERY 5: Get followup efficiency in one query
        followup_efficiency_query = db.session.query(
            func.count(Lead.id).filter(Lead.followup_date.isnot(None))
        )
        if base_conditions:
            followup_efficiency_query = followup_efficiency_query.filter(*base_conditions)
        
        leads_with_followups = followup_efficiency_query.scalar() or 0
        followup_efficiency = (leads_with_followups / total_leads * 100) if total_leads > 0 else 0
        
        # QUERY 6: Get current pending followups count by user (for calculations)
        current_pending_by_user = dict(
            db.session.query(
                Lead.creator_id,
                func.count(Lead.id)
            ).filter(
                Lead.creator_id.in_(user_ids),
                Lead.followup_date >= target_date_utc,
                Lead.followup_date < next_day_utc
            ).group_by(Lead.creator_id).all()
        )
        
        # QUERY 7: Get today's created leads by user
        created_today_by_user = dict(
            db.session.query(
                Lead.creator_id,
                func.count(Lead.id)
            ).filter(
                Lead.creator_id.in_(user_ids),
                Lead.created_at >= target_date_utc,
                Lead.created_at < next_day_utc
            ).group_by(Lead.creator_id).all()
        )
        
        # QUERY 8: Get status counts by user (all time)
        status_by_user = defaultdict(lambda: defaultdict(int))
        status_results = db.session.query(
            Lead.creator_id,
            Lead.status,
            func.count(Lead.id)
        ).filter(
            Lead.creator_id.in_(user_ids)
        ).group_by(Lead.creator_id, Lead.status).all()
        
        for creator_id, status, count in status_results:
            status_by_user[creator_id][status] = count
        
        # FIXED: Calculate metrics based on 5AM snapshot
        user_performance_list = []
        
        for user in users:
            user_id = user.id
            
            # FIXED: Initial followups fixed at 5AM
            user_initial_count = initial_counts_by_user.get(user_id, 0)
            
            # FIXED: Current pending count
            user_current_pending = current_pending_by_user.get(user_id, 0) 
            
            # FIXED: Worked followups = Initial - Current Pending (but not negative)
            user_worked_count = max(0, user_initial_count - user_current_pending)
            
            # FIXED: Completion rate based on 5AM snapshot
            user_completion_rate = round((user_worked_count / user_initial_count * 100), 1) if user_initial_count > 0 else 0
            
            user_leads_created = created_today_by_user.get(user_id, 0)
            
            # Get status counts for this user
            user_statuses = status_by_user[user_id]
            confirmed_count = user_statuses.get('Confirmed', 0)
            completed_count = user_statuses.get('Completed', 0)
            
            # FIXED: Team Performance - Daily Progress calculations
            # Assigned = Fixed at 5AM
            assigned_count = user_initial_count
            # Worked = Followup dates changed from today to future date
            worked_count = user_worked_count
            # Pending = Assigned - Worked
            pending_count = max(0, assigned_count - worked_count)
            
            user_performance_list.append({
                'user': user,
                'initial_followups': assigned_count,  # Fixed at 5AM
                'pending_followups': pending_count,   # Calculated: Assigned - Worked
                'worked_followups': worked_count,     # Leads moved from today
                'completion_rate': user_completion_rate,
                'leads_created': user_leads_created,
                'confirmed': confirmed_count,
                'completed': completed_count,
                'assigned': assigned_count,           # Team Performance - Assigned
                'worked': worked_count,               # Team Performance - Worked  
                'pending': pending_count,             # Team Performance - Pending
                'original_assignment': user_initial_count,  # Original 5AM assignment
                'new_additions': max(0, user_current_pending - user_initial_count)  # New leads added today
            })
        
        # Sort by completion rate (highest first), then by initial followups
        user_performance_list.sort(key=lambda x: (x['completion_rate'], x['initial_followups']), reverse=True)
        
        # FIXED: Calculate overall metrics using 5AM snapshot data
        if current_user.is_admin and selected_user_id:
            # For admin viewing specific user
            try:
                user_id = int(selected_user_id)
                initial_followups_count = initial_counts_by_user.get(user_id, 0)
                current_pending_count = current_pending_by_user.get(user_id, 0)
            except ValueError:
                initial_followups_count = sum(initial_counts_by_user.values())
                current_pending_count = len(current_followups)
        elif current_user.is_admin:
            # For admin viewing all users
            initial_followups_count = sum(initial_counts_by_user.values())
            current_pending_count = len(current_followups)
        else:
            # For regular user
            initial_followups_count = initial_counts_by_user.get(current_user.id, 0)
            current_pending_count = current_pending_by_user.get(current_user.id, 0)
        
        # FIXED: Completion metrics based on 5AM snapshot
        completed_followups = max(0, initial_followups_count - current_pending_count)
        completion_rate = round((completed_followups / initial_followups_count * 100), 1) if initial_followups_count > 0 else 0
        
        # Mobile number mapping for team members
        USER_MOBILE_MAPPING = {
            'Hemlata': '9672562111',
            'Sneha': '+919672764111'
        }
        
        return {
            'todays_followups': current_followups,                    # Current followups for display
            'daily_leads_count': daily_leads_count,
            'user_performance': user_performance_list,
            'status_counts': status_counts,
            'users': users,
            'selected_date': selected_date,
            'selected_user_id': selected_user_id,
            'total_leads': total_leads,
            'followup_efficiency': followup_efficiency,
            'initial_followups_count': initial_followups_count,       # FIXED: From 5AM snapshot
            'completion_rate': completion_rate,                       # FIXED: Based on 5AM snapshot
            'completed_followups': completed_followups,               # FIXED: Calculated from snapshot
            'current_pending_count': current_pending_count,           # Current pending count
            'USER_MOBILE_MAPPING': USER_MOBILE_MAPPING
        }
        
    except Exception as e:
        current_app.logger.error(f"Optimized dashboard error: {str(e)}")
        raise e


def get_optimized_initial_followup_counts(user_ids, date, db, get_initial_followup_count):
    """
    FIXED: Get initial followup counts from 5AM snapshot with fallback calculation
    """
    # Import here to avoid circular imports
    try:
        from application import DailyFollowupCount, Lead
    except ImportError:
        from application_eb import DailyFollowupCount, Lead
    
    # Try to get from 5AM snapshot table first
    daily_counts = db.session.query(DailyFollowupCount).filter(
        DailyFollowupCount.user_id.in_(user_ids),
        DailyFollowupCount.date == date
    ).all()
    
    cached_counts = {dc.user_id: dc.initial_count for dc in daily_counts}
    
    # For users not in cache, calculate current count as fallback
    missing_users = [uid for uid in user_ids if uid not in cached_counts]
    
    if missing_users:
        # Get timezone
        ist = pytz.timezone('Asia/Kolkata')
        
        # Calculate for missing users - use current count as fallback
        start_datetime = ist.localize(datetime.combine(date, time.min))
        end_datetime = start_datetime + timedelta(days=1)
        
        # Convert to UTC for query
        start_datetime_utc = start_datetime.astimezone(pytz.UTC)
        end_datetime_utc = end_datetime.astimezone(pytz.UTC)
        
        missing_counts = dict(
            db.session.query(
                Lead.creator_id,
                func.count(Lead.id)
            ).filter(
                Lead.creator_id.in_(missing_users),
                Lead.followup_date >= start_datetime_utc,
                Lead.followup_date < end_datetime_utc
            ).group_by(Lead.creator_id).all()
        )
        
        # Store in cache for next time
        for user_id in missing_users:
            count = missing_counts.get(user_id, 0)
            cached_counts[user_id] = count
            
            # Save to database for future use
            daily_count = DailyFollowupCount(
                user_id=user_id,
                date=date,
                initial_count=count
            )
            db.session.add(daily_count)
        
        try:
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f"Error saving daily counts: {e}")
    
    return cached_counts 