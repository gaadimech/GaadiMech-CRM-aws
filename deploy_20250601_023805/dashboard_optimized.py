"""
Optimized Dashboard Functions for Better Performance
This file contains optimized versions of dashboard queries that reduce database hits
and improve loading times significantly.
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
    Optimized dashboard data fetching that reduces database queries from ~20+ to ~5-8 queries
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
        
        # OPTIMIZED QUERY 1: Get today's followups with minimal data transfer
        todays_followups_query = db.session.query(Lead).filter(
            Lead.followup_date >= target_date_utc,
            Lead.followup_date < next_day_utc
        )
        if base_conditions:
            todays_followups_query = todays_followups_query.filter(*base_conditions)
        
        todays_followups = todays_followups_query.order_by(Lead.followup_date.asc()).all()
        
        # Convert followups to IST for display
        for followup in todays_followups:
            if followup.followup_date:
                followup.followup_date = utc_to_ist(followup.followup_date)
            if followup.created_at:
                followup.created_at = utc_to_ist(followup.created_at)
            if followup.modified_at:
                followup.modified_at = utc_to_ist(followup.modified_at)
        
        # OPTIMIZED QUERY 2: Get daily leads count
        daily_leads_count_query = db.session.query(func.count(Lead.id)).filter(
            Lead.created_at >= target_date_utc,
            Lead.created_at < next_day_utc
        )
        if base_conditions:
            daily_leads_count_query = daily_leads_count_query.filter(*base_conditions)
        
        daily_leads_count = daily_leads_count_query.scalar() or 0
        
        # OPTIMIZED QUERY 3: Get status counts in a single query
        status_counts_query = db.session.query(
            Lead.status,
            func.count(Lead.id)
        ).group_by(Lead.status)
        
        if base_conditions:
            status_counts_query = status_counts_query.filter(*base_conditions)
        
        status_counts = dict(status_counts_query.all())
        if not status_counts:
            status_counts = {'Needs Followup': 0}
        
        # OPTIMIZED QUERY 4: Get total leads count
        total_leads_query = db.session.query(func.count(Lead.id))
        if base_conditions:
            total_leads_query = total_leads_query.filter(*base_conditions)
        
        total_leads = total_leads_query.scalar() or 0
        
        # OPTIMIZED QUERY 5: Get followup efficiency in one query
        followup_efficiency_query = db.session.query(
            func.count(Lead.id).filter(Lead.followup_date.isnot(None))
        )
        if base_conditions:
            followup_efficiency_query = followup_efficiency_query.filter(*base_conditions)
        
        leads_with_followups = followup_efficiency_query.scalar() or 0
        followup_efficiency = (leads_with_followups / total_leads * 100) if total_leads > 0 else 0
        
        # OPTIMIZED: Batch get initial followup counts for all users at once
        user_ids = [user.id for user in users]
        initial_counts_by_user = get_optimized_initial_followup_counts(
            user_ids, target_date.date(), db, get_initial_followup_count
        )
        
        # OPTIMIZED QUERY 6: Get user performance data in bulk queries
        user_performance_list = []
        
        if users:
            # Bulk query for today's pending followups by user
            pending_followups_by_user = dict(
                db.session.query(
                    Lead.creator_id,
                    func.count(Lead.id)
                ).filter(
                    Lead.creator_id.in_(user_ids),
                    Lead.followup_date >= target_date_utc,
                    Lead.followup_date < next_day_utc
                ).group_by(Lead.creator_id).all()
            )
            
            # Bulk query for today's created leads by user
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
            
            # Bulk query for status counts by user (all time)
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
            
            # Build user performance data
            for user in users:
                user_id = user.id
                
                # Get initial followup count from batch result
                user_initial_count = initial_counts_by_user.get(user_id, 0)
                
                # Get current pending count
                user_pending_count = pending_followups_by_user.get(user_id, 0)
                
                # Calculate metrics
                effective_assigned = max(user_initial_count, user_pending_count)
                
                if user_pending_count > user_initial_count:
                    user_worked_count = 0
                else:
                    user_worked_count = user_initial_count - user_pending_count
                
                user_completion_rate = round((user_worked_count / user_initial_count * 100), 1) if user_initial_count > 0 else 0
                
                user_leads_created = created_today_by_user.get(user_id, 0)
                
                # Get status counts for this user
                user_statuses = status_by_user[user_id]
                confirmed_count = user_statuses.get('Confirmed', 0)
                completed_count = user_statuses.get('Completed', 0)
                
                user_performance_list.append({
                    'user': user,
                    'initial_followups': effective_assigned,
                    'pending_followups': user_pending_count,
                    'worked_followups': user_worked_count,
                    'completion_rate': user_completion_rate,
                    'leads_created': user_leads_created,
                    'confirmed': confirmed_count,
                    'completed': completed_count,
                    'original_assignment': user_initial_count,
                    'new_additions': max(0, user_pending_count - user_initial_count)
                })
        
        # Sort by completion rate (highest first), then by initial followups
        user_performance_list.sort(key=lambda x: (x['completion_rate'], x['initial_followups']), reverse=True)
        
        # Calculate overall metrics using batch results
        if current_user.is_admin and selected_user_id:
            # For admin viewing specific user
            try:
                user_id = int(selected_user_id)
                initial_followups_count = initial_counts_by_user.get(user_id, len(todays_followups))
            except ValueError:
                initial_followups_count = len(todays_followups)
        elif current_user.is_admin:
            # For admin viewing all users
            initial_followups_count = sum(initial_counts_by_user.values())
        else:
            # For regular user
            initial_followups_count = initial_counts_by_user.get(current_user.id, 0)
        
        # Calculate completion rate
        pending_count = len(todays_followups)
        
        # If there are more current followups than initial assignment,
        # it means new leads were added during the day
        if pending_count > initial_followups_count:
            # Completion rate based on how many were completed from the initial assignment
            completed_followups = 0  # None from initial assignment completed yet
            completion_rate = 0.0
        else:
            # Standard completion rate calculation
            completed_followups = max(0, initial_followups_count - pending_count)
            completion_rate = round((completed_followups / initial_followups_count * 100), 1) if initial_followups_count > 0 else 0
        
        # Mobile number mapping for team members
        USER_MOBILE_MAPPING = {
            'Hemlata': '9672562111',
            'Sneha': '+919672764111'
        }
        
        return {
            'todays_followups': todays_followups,
            'daily_leads_count': daily_leads_count,
            'user_performance': user_performance_list,
            'status_counts': status_counts,
            'users': users,
            'selected_date': selected_date,
            'selected_user_id': selected_user_id,
            'total_leads': total_leads,
            'followup_efficiency': followup_efficiency,
            'initial_followups_count': initial_followups_count,
            'completion_rate': completion_rate,
            'completed_followups': completed_followups,
            'USER_MOBILE_MAPPING': USER_MOBILE_MAPPING
        }
        
    except Exception as e:
        current_app.logger.error(f"Optimized dashboard error: {str(e)}")
        raise e


def get_optimized_initial_followup_counts(user_ids, date, db, get_initial_followup_count):
    """
    Optimized function to get initial followup counts for multiple users at once
    """
    # Import here to avoid circular imports - use the correct module name
    from app import DailyFollowupCount, Lead
    
    # Try to get from cache table first
    daily_counts = db.session.query(DailyFollowupCount).filter(
        DailyFollowupCount.user_id.in_(user_ids),
        DailyFollowupCount.date == date
    ).all()
    
    cached_counts = {dc.user_id: dc.initial_count for dc in daily_counts}
    
    # For users not in cache, calculate and store
    missing_users = [uid for uid in user_ids if uid not in cached_counts]
    
    if missing_users:
        # Calculate for missing users in one query
        start_datetime = datetime.combine(date, time.min)
        end_datetime = datetime.combine(date + timedelta(days=1), time.min)
        
        missing_counts = dict(
            db.session.query(
                Lead.creator_id,
                func.count(Lead.id)
            ).filter(
                Lead.creator_id.in_(missing_users),
                Lead.followup_date >= start_datetime,
                Lead.followup_date < end_datetime
            ).group_by(Lead.creator_id).all()
        )
        
        # Store in cache
        for user_id in missing_users:
            count = missing_counts.get(user_id, 0)
            cached_counts[user_id] = count
            
            # Save to database
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