from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, make_response
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from datetime import datetime, timedelta
from werkzeug.security import generate_password_hash, check_password_hash
import re
import os
from dotenv import load_dotenv
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address   
from zoneinfo import ZoneInfo
from flask_migrate import Migrate
from pytz import timezone
import pytz
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
import atexit



load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'gaadimech123')  # Provide a default secret key

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres.qcvfmiqzkfhinxlhknnd:gaadimech123@aws-0-ap-south-1.pooler.supabase.com:6543/postgres")
if DATABASE_URL is None:
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///crm.db'
else:
    # Handle Render.com's Postgres URL format
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)
    app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize database and login manager
db = SQLAlchemy(app)
migrate = Migrate(app, db)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

print("Database connected")

# Configure rate limiter
limiter = Limiter(
    key_func=get_remote_address,
    app=app,
    storage_uri="memory://"
)

# Get IST timezone
ist = timezone('Asia/Kolkata')

# Mobile number mapping for team members (temporary solution)
USER_MOBILE_MAPPING = {
    'Hemlata': '9672562111',
    'Sneha': '+919672764111'
}

# Database Models
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    leads = db.relationship('Lead', backref='creator', lazy=True)

    def set_password(self, password):
        self.password_hash = password  # Store plain text password

    def check_password(self, password):
        return self.password_hash == password  # Compare plain text passwords

class DailyFollowupCount(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    initial_count = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(ist))
    
    __table_args__ = (db.UniqueConstraint('date', 'user_id', name='unique_daily_count'),)

class Lead(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    customer_name = db.Column(db.String(100), nullable=False)
    mobile = db.Column(db.String(12), nullable=False)
    car_registration = db.Column(db.String(20), nullable=True)
    followup_date = db.Column(db.DateTime, nullable=False)
    remarks = db.Column(db.Text)
    status = db.Column(db.String(20), nullable=False, default='Needs Followup')
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(ist))
    modified_at = db.Column(db.DateTime, default=lambda: datetime.now(ist), onupdate=lambda: datetime.now(ist))
    creator_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    # Update the constraint to include new status values
    __table_args__ = (
        db.CheckConstraint(
            status.in_(['Did Not Pick Up', 'Needs Followup', 'Confirmed', 'Open', 'Completed', 'Feedback']),
            name='valid_status'
        ),
    )

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("20 per minute")
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))

    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        print(f"Received username: {username}")  # Debug statement
        print(f"Received password: {password}")  # Debug statement
        
        try:
            user = User.query.filter_by(username=username).first()
            print(f"User found: {user}")  # Debug statement
            
            if user:
                if user.check_password(password):
                    login_user(user, remember=True)
                    print(f"Password check completed")  # Debug statement
                    # Get next page from args or default to index
                    next_page = request.args.get('next')
                    if not next_page or not next_page.startswith('/'):
                        next_page = url_for('index')
                    
                    return redirect(next_page)
                else:
                    flash('Invalid password', 'error')
                    print(f"Password check failed for user: {username}")  # Log the failure
            else:
                flash('Invalid username', 'error')
                print(f"User not found: {username}")  # Log the failure
        except Exception as e:
            flash('An error occurred during login. Please try again.', 'error')
            print(f"Login error: {str(e)}")  # Log the error
    
    return render_template('login.html')




app.config.update(
    SESSION_COOKIE_SECURE=app.config.get('PREFERRED_URL_SCHEME') == 'https',
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
    REMEMBER_COOKIE_SECURE=app.config.get('PREFERRED_URL_SCHEME') == 'https',
    REMEMBER_COOKIE_HTTPONLY=True,
    REMEMBER_COOKIE_DURATION=timedelta(hours=24)
)

# Update login manager configuration 
login_manager.session_protection = "strong"
login_manager.refresh_view = "login"
login_manager.needs_refresh_message = "Please login again to confirm your identity"
login_manager.needs_refresh_message_category = "info"

@app.route('/get_team_members')
@login_required
def get_team_members():
    if current_user.is_admin:
        team_members = User.query.filter(User.id != current_user.id).all()
        return jsonify([{'id': user.id, 'name': user.name} for user in team_members])
    return jsonify([])

@app.route('/open_whatsapp/<mobile>')
@login_required
def open_whatsapp(mobile):
    cleaned_mobile = ''.join(filter(str.isdigit, mobile))
    if len(cleaned_mobile) == 10:
        cleaned_mobile = '91' + cleaned_mobile
    
    user_agent = request.headers.get('User-Agent')
    if 'Mobile' in user_agent:
        whatsapp_url = f"whatsapp://send?phone={cleaned_mobile}"
    else:
        whatsapp_url = f"https://web.whatsapp.com/send?phone={cleaned_mobile}"
    
    return jsonify({'url': whatsapp_url})


@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/')
@login_required
def index():
    users = User.query.all()
    return render_template('index.html', users=users)

def utc_to_ist(utc_dt):
    if utc_dt is None:
        return None
    if utc_dt.tzinfo is None:
        utc_dt = pytz.UTC.localize(utc_dt)
    ist = pytz.timezone('Asia/Kolkata')
    return utc_dt.astimezone(ist)

def update_daily_followup_count(user_id, date, count):
    """Update or create daily followup count record"""
    try:
        daily_count = DailyFollowupCount.query.filter_by(
            user_id=user_id, 
            date=date
        ).first()
        
        if daily_count:
            # Update existing record only if new count is higher (initial assignment)
            if count > daily_count.initial_count:
                daily_count.initial_count = count
        else:
            # Create new record
            daily_count = DailyFollowupCount(
                user_id=user_id,
                date=date,
                initial_count=count
            )
            db.session.add(daily_count)
        
        db.session.commit()
        return daily_count.initial_count
    except Exception as e:
        print(f"Error updating daily followup count: {e}")
        db.session.rollback()
        return count  # Return the current count as fallback

def get_initial_followup_count(user_id, date):
    """Get the initial followup count for a user on a specific date"""
    daily_count = DailyFollowupCount.query.filter_by(
        user_id=user_id, 
        date=date
    ).first()
    
    if daily_count:
        return daily_count.initial_count
    else:
        # If no record exists, return current count and create record
        current_count = Lead.query.filter(
            Lead.creator_id == user_id,
            Lead.followup_date >= datetime.combine(date, datetime.min.time()),
            Lead.followup_date < datetime.combine(date + timedelta(days=1), datetime.min.time())
        ).count()
        
        update_daily_followup_count(user_id, date, current_count)
        return current_count

def capture_daily_snapshot():
    """Capture daily snapshot of followup counts at 5AM IST - this fixes the day's workload"""
    try:
        print(f"Running daily snapshot at {datetime.now(ist)}")
        
        # Get today's date in IST
        today = datetime.now(ist).date()
        today_start = ist.localize(datetime.combine(today, datetime.min.time()))
        tomorrow_start = today_start + timedelta(days=1)
        
        # Convert to UTC for database queries
        today_start_utc = today_start.astimezone(pytz.UTC)
        tomorrow_start_utc = tomorrow_start.astimezone(pytz.UTC)
        
        # Get all users
        users = User.query.all()
        
        for user in users:
            # Count leads scheduled for today for this user
            followup_count = Lead.query.filter(
                Lead.creator_id == user.id,
                Lead.followup_date >= today_start_utc,
                Lead.followup_date < tomorrow_start_utc
            ).count()
            
            # Create or update the daily count record
            daily_count = DailyFollowupCount.query.filter_by(
                user_id=user.id,
                date=today
            ).first()
            
            if daily_count:
                # Update existing record - always override with current snapshot
                daily_count.initial_count = followup_count
            else:
                # Create new record
                daily_count = DailyFollowupCount(
                    user_id=user.id,
                    date=today,
                    initial_count=followup_count
                )
                db.session.add(daily_count)
            
            print(f"User {user.name}: {followup_count} followups fixed for {today}")
        
        db.session.commit()
        print(f"Daily snapshot completed successfully for {today}")
        
    except Exception as e:
        print(f"Error in daily snapshot: {e}")
        db.session.rollback()

def setup_scheduler():
    """Setup the background scheduler for daily snapshot"""
    scheduler = BackgroundScheduler()
    
    # Schedule daily snapshot at 5:00 AM IST
    scheduler.add_job(
        func=capture_daily_snapshot,
        trigger=CronTrigger(hour=5, minute=0, timezone='Asia/Kolkata'),
        id='daily_snapshot',
        name='Daily Followup Snapshot at 5AM IST',
        replace_existing=True
    )
    
    scheduler.start()
    print("Scheduler started - Daily snapshot will run at 5:00 AM IST")
    
    # Shut down the scheduler when exiting the app
    atexit.register(lambda: scheduler.shutdown())
    
    return scheduler

@app.route('/add_lead', methods=['POST'])
@login_required
@limiter.limit("30 per minute")
def add_lead():
    try:
        customer_name = request.form.get('customer_name')
        mobile = request.form.get('mobile')
        car_registration = request.form.get('car_registration')
        # followup_date = request.form.get('followup_date')
        remarks = request.form.get('remarks')
        status = request.form.get('status')

        if not status or status not in ['Did Not Pick Up', 'Needs Followup', 'Confirmed', 'Open', 'Completed', 'Feedback']:
            status = 'Needs Followup'

        followup_date = datetime.strptime(request.form.get('followup_date'), '%Y-%m-%d')
        ist = pytz.timezone('Asia/Kolkata')
        followup_date = ist.localize(followup_date)
        followup_date_utc = followup_date.astimezone(pytz.UTC)

        if not all([customer_name, mobile, followup_date]):
            flash('All required fields must be filled', 'error')
            return redirect(url_for('index'))

        if not re.match(r'^\d{10}$|^\d{12}$', mobile):
            flash('Mobile number must be either 10 or 12 digits', 'error')
            return redirect(url_for('index'))

        new_lead = Lead(
            customer_name=customer_name,
            mobile=mobile,
            car_registration=car_registration,
            followup_date=followup_date,
            remarks=remarks,
            status=status,
            creator_id=current_user.id,
            created_at=datetime.now(ist),
            modified_at=datetime.now(ist)
        )
        
        db.session.add(new_lead)
        db.session.commit()
        
        flash('Lead added successfully!', 'success')
    except Exception as e:
        db.session.rollback()
        flash('Error adding lead. Please try again.', 'error')
        print(f"Error adding lead: {str(e)}")
    
    return redirect(url_for('index'))

@app.route('/followups')
@login_required
def followups():
    try:
        team_members = User.query.all() if current_user.is_admin else []
        selected_member_id = request.args.get('team_member_id', '')
        date = request.args.get('date', '')
        created_date = request.args.get('created_date', '')
        modified_date = request.args.get('modified_date', '')
        car_registration = request.args.get('car_registration', '')
        mobile = request.args.get('mobile', '')  # Get mobile number from query params
        status_filter = request.args.get('status', '')
        
        query = Lead.query

        ist = pytz.timezone('Asia/Kolkata')

        # User-based filtering
        if current_user.is_admin:
            if selected_member_id:
                query = query.filter(Lead.creator_id == selected_member_id)
        else:
            query = query.filter(Lead.creator_id == current_user.id)

        # Apply all filters if they exist
        if status_filter:
            query = query.filter(Lead.status == status_filter)
            
        if date:
            start_date = datetime.strptime(date, '%Y-%m-%d')
            start_date = ist.localize(start_date)  # Add IST timezone
            end_date = start_date + timedelta(days=1)  # Next day
            
            # Convert to UTC for database query
            start_date_utc = start_date.astimezone(pytz.UTC)
            end_date_utc = end_date.astimezone(pytz.UTC)
            
            query = query.filter(
                Lead.followup_date >= start_date_utc,
                Lead.followup_date < end_date_utc
            )
        
        if created_date:
            # Convert the selected created_date to UTC range
            start_date = datetime.strptime(created_date, '%Y-%m-%d')
            start_date = ist.localize(start_date)
            end_date = start_date + timedelta(days=1)
            
            start_date_utc = start_date.astimezone(pytz.UTC)
            end_date_utc = end_date.astimezone(pytz.UTC)
            
            query = query.filter(
                Lead.created_at >= start_date_utc,
                Lead.created_at < end_date_utc
            )

        if current_user.is_admin and modified_date:
            start_date = datetime.strptime(modified_date, '%Y-%m-%d')
            start_date = ist.localize(start_date)
            end_date = start_date + timedelta(days=1)
            
            start_date_utc = start_date.astimezone(pytz.UTC)
            end_date_utc = end_date.astimezone(pytz.UTC)
            
            query = query.filter(
                Lead.modified_at >= start_date_utc,
                Lead.modified_at < end_date_utc
            )
        
        if car_registration:
            query = query.filter(Lead.car_registration.ilike(f'%{car_registration}%'))
            
        # Add mobile number filter
        if mobile:
            query = query.filter(Lead.mobile.ilike(f'%{mobile}%'))
        
        # Convert to IST timezone
        followups = query.order_by(Lead.created_at.desc()).all()

        for followup in followups:
            followup.created_at = utc_to_ist(followup.created_at)
            followup.modified_at = utc_to_ist(followup.modified_at)
            followup.followup_date = utc_to_ist(followup.followup_date)
        
        # # Ensure all datetime objects are timezone-aware
        # for followup in followups:
        #     if followup.created_at.tzinfo is None:
        #         followup.created_at = pytz.utc.localize(followup.created_at)
        #     if followup.modified_at.tzinfo is None:
        #         followup.modified_at = pytz.utc.localize(followup.modified_at)
        #     if followup.followup_date.tzinfo is None:
        #         followup.followup_date = pytz.utc.localize(followup.followup_date)
        
        return render_template('followups.html', 
                             followups=followups, 
                             team_members=team_members,
                             selected_member_id=selected_member_id,
                             timedelta=timedelta)  # Pass timedelta to template
    except Exception as e:
        flash('Error loading followups. Please try again.', 'error')
        print(f"Error loading followups: {str(e)}")
        return redirect(url_for('index'))

@app.route('/edit_lead/<int:lead_id>', methods=['GET', 'POST'])
@login_required
def edit_lead(lead_id):
    try:
        lead = Lead.query.get_or_404(lead_id)
        
        if not current_user.is_admin and lead.creator_id != current_user.id:
            flash('You do not have permission to edit this lead', 'error')
            return redirect(url_for('followups'))
            
        if request.method == 'POST':
            lead.customer_name = request.form['customer_name']
            lead.mobile = request.form['mobile']
            lead.car_registration = request.form['car_registration']
            
            # Convert followup_date to IST
            followup_date = datetime.strptime(request.form['followup_date'], '%Y-%m-%d')
            lead.followup_date = ist.localize(followup_date)
            
            lead.remarks = request.form['remarks']
            lead.status = request.form['status']
            lead.modified_at = datetime.now(ist)
            
            db.session.commit()
            flash('Lead updated successfully!', 'success')
            return redirect(url_for('followups'))
        
        lead.followup_date = utc_to_ist(lead.followup_date)
        return render_template('edit_lead.html', lead=lead)
    except Exception as e:
        db.session.rollback()
        flash('Error updating lead. Please try again.', 'error')
        print(f"Error updating lead: {str(e)}")
        return redirect(url_for('followups'))

@app.route('/delete_lead/<int:lead_id>', methods=['POST'])
@login_required
def delete_lead(lead_id):
    try:
        lead = Lead.query.get_or_404(lead_id)
        
        if not current_user.is_admin and lead.creator_id != current_user.id:
            return jsonify({'success': False, 'message': 'Permission denied'})
            
        db.session.delete(lead)
        db.session.commit()
        return jsonify({'success': True})
    except Exception as e:
        db.session.rollback()
        print(f"Error deleting lead: {str(e)}")  # Log the error
        return jsonify({'success': False, 'message': 'Error deleting lead'})

@app.route('/dashboard')
@login_required
def dashboard():
    try:
        # Get date filter from query params (default to today)
        selected_date = request.args.get('date', datetime.now(ist).strftime('%Y-%m-%d'))
        selected_user_id = request.args.get('user_id', '')
        
        # Parse the selected date with better error handling
        try:
            target_date = datetime.strptime(selected_date, '%Y-%m-%d')
            target_date = ist.localize(target_date)
            next_day = target_date + timedelta(days=1)
        except ValueError:
            # If date parsing fails, use today
            target_date = datetime.now(ist).replace(hour=0, minute=0, second=0, microsecond=0)
            next_day = target_date + timedelta(days=1)
            selected_date = target_date.strftime('%Y-%m-%d')
        
        # Convert to UTC for database queries
        target_date_utc = target_date.astimezone(pytz.UTC)
        next_day_utc = next_day.astimezone(pytz.UTC)
        
        # Get all users for admin or current user for regular users
        if current_user.is_admin:
            users = User.query.all()
        else:
            users = [current_user]
            selected_user_id = str(current_user.id)
        
        # Base query setup
        base_query = Lead.query
        if selected_user_id and current_user.is_admin:
            try:
                base_query = base_query.filter(Lead.creator_id == int(selected_user_id))
            except ValueError:
                pass  # Invalid user_id, ignore filter
        elif not current_user.is_admin:
            base_query = base_query.filter(Lead.creator_id == current_user.id)
        
        # 1. Today's Followups (current pending ones)
        todays_followups = base_query.filter(
            Lead.followup_date >= target_date_utc,
            Lead.followup_date < next_day_utc
        ).order_by(Lead.followup_date.asc()).all()
        
        # 1.1. Calculate initial followups count for the selected date and user(s)
        if current_user.is_admin and selected_user_id:
            # For admin viewing specific user
            try:
                user_id = int(selected_user_id)
                initial_followups_count = get_initial_followup_count(user_id, target_date.date())
            except ValueError:
                initial_followups_count = len(todays_followups)
        elif current_user.is_admin:
            # For admin viewing all users
            initial_followups_count = 0
            for user in users:
                initial_followups_count += get_initial_followup_count(user.id, target_date.date())
        else:
            # For regular user
            initial_followups_count = get_initial_followup_count(current_user.id, target_date.date())
        
        # 1.2. Calculate completion rate
        pending_count = len(todays_followups)
        completed_followups = max(0, initial_followups_count - pending_count)
        completion_rate = round((completed_followups / initial_followups_count * 100), 1) if initial_followups_count > 0 else 0
        
        # Convert to IST for display (with safety checks)
        for followup in todays_followups:
            if followup.followup_date:
                followup.followup_date = utc_to_ist(followup.followup_date)
            if followup.created_at:
                followup.created_at = utc_to_ist(followup.created_at)
            if followup.modified_at:
                followup.modified_at = utc_to_ist(followup.modified_at)
        
        # 2. Daily Performance Metrics
        daily_leads = base_query.filter(
            Lead.created_at >= target_date_utc,
            Lead.created_at < next_day_utc
        ).all()
        
        # 3. User performance (enhanced with completion tracking)
        user_performance_list = []
        for user in users:
            # Get user's fixed initial count for today
            user_initial_count = get_initial_followup_count(user.id, target_date.date())
            
            # Count current pending followups for this user
            user_pending_count = base_query.filter(
                Lead.creator_id == user.id,
                Lead.followup_date >= target_date_utc,
                Lead.followup_date < next_day_utc
            ).count()
            
            # Calculate worked upon (completed/rescheduled)
            user_worked_count = max(0, user_initial_count - user_pending_count)
            
            # Calculate user completion rate
            user_completion_rate = round((user_worked_count / user_initial_count * 100), 1) if user_initial_count > 0 else 0
            
            # Get new leads created by this user today
            user_leads_created = Lead.query.filter(
                Lead.creator_id == user.id,
                Lead.created_at >= target_date_utc,
                Lead.created_at < next_day_utc
            ).count()
            
            # Count confirmed and completed statuses
            user_all_leads = Lead.query.filter(Lead.creator_id == user.id).all()
            confirmed_count = len([l for l in user_all_leads if l.status == 'Confirmed'])
            completed_count = len([l for l in user_all_leads if l.status == 'Completed'])
            
            user_performance_list.append({
                'user': user,
                'initial_followups': user_initial_count,
                'pending_followups': user_pending_count,
                'worked_followups': user_worked_count,
                'completion_rate': user_completion_rate,
                'leads_created': user_leads_created,
                'confirmed': confirmed_count,
                'completed': completed_count
            })
        
        # Sort by completion rate (highest first), then by initial followups
        user_performance_list.sort(key=lambda x: (x['completion_rate'], x['initial_followups']), reverse=True)
        
        # 4. Follow-up efficiency
        total_leads = base_query.count()
        leads_with_followups = base_query.filter(Lead.followup_date.isnot(None)).count()
        followup_efficiency = (leads_with_followups / total_leads * 100) if total_leads > 0 else 0
        
        # 5. Status counts for Quick Stats
        status_counts = {}
        all_leads = base_query.all()
        for lead in all_leads:
            status_counts[lead.status] = status_counts.get(lead.status, 0) + 1
        
        # Ensure we have some data to prevent empty Quick Stats
        if not status_counts:
            status_counts = {'Needs Followup': 0}
        
        # Prepare template data with streamlined data
        template_data = {
            'todays_followups': todays_followups,
            'daily_leads_count': len(daily_leads),
            'user_performance': user_performance_list,
            'status_counts': status_counts,
            'users': users,
            'selected_date': selected_date,
            'selected_user_id': selected_user_id,
            'total_leads': total_leads,
            'followup_efficiency': followup_efficiency,
            'initial_followups_count': initial_followups_count,
            'completion_rate': completion_rate,
            'completed_followups': completed_followups
        }
        
        return render_template('dashboard.html', **template_data)
        
    except Exception as e:
        # Log the error for debugging
        print(f"Dashboard error: {str(e)}")
        import traceback
        traceback.print_exc()
        
        # Instead of redirecting (which might cause logout), show a simple dashboard
        flash(f'Dashboard loading error: {str(e)}. Showing simplified view.', 'warning')
        
        # Minimal data for emergency dashboard
        emergency_data = {
            'todays_followups': [],
            'daily_leads_count': 0,
            'user_performance': [],
            'status_counts': {'Needs Followup': 0},
            'users': [current_user] if current_user.is_authenticated else [],
            'selected_date': datetime.now().strftime('%Y-%m-%d'),
            'selected_user_id': '',
            'total_leads': 0,
            'followup_efficiency': 0,
            'initial_followups_count': 0,
            'completion_rate': 0,
            'completed_followups': 0
        }
        
        return render_template('dashboard.html', **emergency_data)

@app.route('/api/dashboard/status-update', methods=['POST'])
@login_required
def update_lead_status():
    try:
        data = request.get_json()
        lead_id = data.get('lead_id')
        new_status = data.get('status')
        
        lead = Lead.query.get_or_404(lead_id)
        
        # Check permissions
        if not current_user.is_admin and lead.creator_id != current_user.id:
            return jsonify({'success': False, 'message': 'Permission denied'})
        
        lead.status = new_status
        lead.modified_at = datetime.now(ist)
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Status updated successfully'})
        
    except Exception as e:
        db.session.rollback()
        print(f"Error updating status: {str(e)}")
        return jsonify({'success': False, 'message': 'Error updating status'})

@app.route('/api/dashboard/quick-followup', methods=['POST'])
@login_required
def add_quick_followup():
    try:
        data = request.get_json()
        lead_id = data.get('lead_id')
        followup_date = data.get('followup_date')
        remarks = data.get('remarks', '')
        
        lead = Lead.query.get_or_404(lead_id)
        
        # Check permissions
        if not current_user.is_admin and lead.creator_id != current_user.id:
            return jsonify({'success': False, 'message': 'Permission denied'})
        
        # Update followup date
        followup_datetime = datetime.strptime(followup_date, '%Y-%m-%d')
        lead.followup_date = ist.localize(followup_datetime)
        if remarks:
            lead.remarks = remarks
        lead.modified_at = datetime.now(ist)
        
        db.session.commit()
        
        return jsonify({'success': True, 'message': 'Followup scheduled successfully'})
        
    except Exception as e:
        db.session.rollback()
        print(f"Error scheduling followup: {str(e)}")
        return jsonify({'success': False, 'message': 'Error scheduling followup'})

@app.route('/api/trigger-snapshot', methods=['POST'])
@login_required
def trigger_manual_snapshot():
    """Manual trigger for daily snapshot - useful for testing or emergency fixes"""
    if not current_user.is_admin:
        return jsonify({'success': False, 'message': 'Admin access required'})
    
    try:
        with app.app_context():
            capture_daily_snapshot()
        return jsonify({'success': True, 'message': 'Daily snapshot completed successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'})

@app.route('/init_db', methods=['GET'])
def initialize_database():
    if not os.getenv('ALLOW_DB_INIT', '').lower() == 'False':
        return "Database initialization is disabled", 403
    
    try:
        with app.app_context():
            # Create all tables
            db.create_all()
            
            # Check if admin user exists
            admin = User.query.filter_by(username='admin').first()
            if not admin:
                # Create admin user
                admin = User(
                    username='admin',
                    name='Administrator',
                    is_admin=True
                )
                admin.set_password('admin123')
                db.session.add(admin)
                
                # Create test user
                test_user = User(
                    username='test_user',
                    name='Test User',
                    is_admin=False
                )
                test_user.set_password('test123')
                db.session.add(test_user)
                
                db.session.commit()
                return "Database initialized successfully!", 200
            else:
                return "Database already initialized!", 200
                
    except Exception as e:
        db.session.rollback()
        error_message = f"Error initializing database: {str(e)}"
        print(error_message)  # Log the error
        return error_message, 500

@app.route('/api/user-followup-numbers/<int:user_id>')
@login_required
def get_user_followup_numbers(user_id):
    """Get today's followup phone numbers for a specific user"""
    if not current_user.is_admin:
        return jsonify({'success': False, 'message': 'Admin access required'})
    
    try:
        # Get today's date in IST
        today = datetime.now(ist).date()
        today_start = ist.localize(datetime.combine(today, datetime.min.time()))
        tomorrow_start = today_start + timedelta(days=1)
        
        # Convert to UTC for database queries
        today_start_utc = today_start.astimezone(pytz.UTC)
        tomorrow_start_utc = tomorrow_start.astimezone(pytz.UTC)
        
        # Get user details
        user = User.query.get_or_404(user_id)
        user_mobile = USER_MOBILE_MAPPING.get(user.name, None)
        
        # Get today's followups for this user
        followups = Lead.query.filter(
            Lead.creator_id == user_id,
            Lead.followup_date >= today_start_utc,
            Lead.followup_date < tomorrow_start_utc
        ).all()
        
        # Extract phone numbers and customer details
        followup_list = []
        for lead in followups:
            followup_list.append({
                'customer_name': lead.customer_name,
                'mobile': lead.mobile,
                'car_registration': lead.car_registration or 'N/A',
                'remarks': lead.remarks or 'No remarks',
                'status': lead.status
            })
        
        return jsonify({
            'success': True,
            'user_name': user.name,
            'user_mobile': user_mobile,
            'total_followups': len(followup_list),
            'followups': followup_list
        })
        
    except Exception as e:
        print(f"Error getting user followup numbers: {e}")
        return jsonify({'success': False, 'message': f'Error: {str(e)}'})

# Error handlers
@app.errorhandler(404)
def not_found_error(error):
    return render_template('error.html', error="404 - Page Not Found"), 404

@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()  # In case of database error
    return render_template('error.html', error="500 - Internal Server Error"), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    
    # Initialize the scheduler for daily snapshots
    with app.app_context():
        setup_scheduler()
        
        # Optionally run initial snapshot if none exists for today
        today = datetime.now(ist).date()
        existing_records = DailyFollowupCount.query.filter_by(date=today).first()
        if not existing_records:
            print("No snapshot found for today, running initial snapshot...")
            capture_daily_snapshot()
    
    app.run(host='0.0.0.0', port=port, debug=True)
