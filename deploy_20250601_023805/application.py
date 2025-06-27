from flask import Flask, render_template, request, redirect, url_for, flash, jsonify, make_response
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from datetime import datetime, timedelta, time
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

application = Flask(__name__)
application.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'GaadiMech2024!')  # Provide a default secret key

# Database configuration for AWS RDS
DATABASE_URL = os.getenv("DATABASE_URL")

# AWS RDS fallback configuration
if not DATABASE_URL:
    RDS_HOST = os.getenv("RDS_HOST", "gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
    RDS_DB = os.getenv("RDS_DB", "crmportal")
    RDS_USER = os.getenv("RDS_USER", "postgres")
    RDS_PASSWORD = os.getenv("RDS_PASSWORD", "GaadiMech2024!")
    RDS_PORT = os.getenv("RDS_PORT", "5432")
    
    DATABASE_URL = f"postgresql+psycopg://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"

# Ensure we're using postgresql+psycopg:// format for psycopg3 compatibility
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+psycopg://", 1)
elif DATABASE_URL.startswith("postgresql://"):
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+psycopg://", 1)

application.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
application.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# AWS RDS optimized settings
application.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 5,
    'pool_recycle': 1800,
    'pool_pre_ping': True,
    'connect_args': {
        'connect_timeout': 60,
        'sslmode': 'prefer'
    }
}

# Initialize database and login manager
db = SQLAlchemy(application)
migrate = Migrate(application, db)
login_manager = LoginManager()
login_manager.init_app(application)
login_manager.login_view = 'login'

# Simple in-memory cache for development (avoiding Flask-Caching complexity)
dashboard_cache_store = {}

print("Database connected")

# Configure rate limiter
limiter = Limiter(
    key_func=get_remote_address,
    app=application,
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

@application.route('/login', methods=['GET', 'POST'])
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




application.config.update(
    SESSION_COOKIE_SECURE=application.config.get('PREFERRED_URL_SCHEME') == 'https',
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
    REMEMBER_COOKIE_SECURE=application.config.get('PREFERRED_URL_SCHEME') == 'https',
    REMEMBER_COOKIE_HTTPONLY=True,
    REMEMBER_COOKIE_DURATION=timedelta(hours=24),
    PERMANENT_SESSION_LIFETIME=timedelta(hours=24)
)

# Update login manager configuration for mobile compatibility
login_manager.session_protection = "basic"  # Changed from "strong" to "basic" for mobile compatibility
login_manager.refresh_view = "login"
login_manager.needs_refresh_message = "Please login again to confirm your identity"
login_manager.needs_refresh_message_category = "info"

@application.route('/get_team_members')
@login_required
def get_team_members():
    if current_user.is_admin:
        team_members = User.query.filter(User.id != current_user.id).all()
        return jsonify([{'id': user.id, 'name': user.name} for user in team_members])
    return jsonify([])

@application.route('/open_whatsapp/<mobile>')
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


@application.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@application.route('/')
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
        # Create start and end datetime objects properly
        start_datetime = datetime.combine(date, time.min)
        end_datetime = datetime.combine(date + timedelta(days=1), time.min)
        
        current_count = Lead.query.filter(
            Lead.creator_id == user_id,
            Lead.followup_date >= start_datetime,
            Lead.followup_date < end_datetime
        ).count()
        
        update_daily_followup_count(user_id, date, current_count)
        return current_count

def capture_daily_snapshot():
    """Capture daily snapshot of followup counts at 5AM IST - this fixes the day's workload"""
    try:
        print(f"Running daily snapshot at {datetime.now(ist)}")
        
        # Get today's date in IST
        today = datetime.now(ist).date()
        today_start = ist.localize(datetime.combine(today, time.min))
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

@application.route('/add_lead', methods=['POST'])
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

@application.route('/followups')
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
        
        # Add pagination for better performance with large datasets
        page = request.args.get('page', 1, type=int)
        per_page = 50  # Limit to 50 results per page

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
        
        # Remove pagination and get all matching results
        followups = query.order_by(Lead.created_at.desc()).all()

        # Convert to IST timezone efficiently
        for followup in followups:
            followup.created_at = utc_to_ist(followup.created_at)
            followup.modified_at = utc_to_ist(followup.modified_at)
            followup.followup_date = utc_to_ist(followup.followup_date)
        
        return render_template('followups.html', 
                             followups=followups, 
                             team_members=team_members,
                             selected_member_id=selected_member_id,
                             timedelta=timedelta)
    except Exception as e:
        flash('Error loading followups. Please try again.', 'error')
        print(f"Error loading followups: {str(e)}")
        return redirect(url_for('index'))

@application.route('/edit_lead/<int:lead_id>', methods=['GET', 'POST'])
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

@application.route('/delete_lead/<int:lead_id>', methods=['POST'])
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

@application.route('/dashboard')
@login_required
def dashboard():
    try:
        # Get date filter from query params (default to today)
        selected_date = request.args.get('date', datetime.now(ist).strftime('%Y-%m-%d'))
        selected_user_id = request.args.get('user_id', '')
        
        # Check cache first for performance
        cached_data = dashboard_cache_store.get((current_user.id, selected_date, selected_user_id))
        
        if cached_data:
            return render_template('dashboard.html', **cached_data)
        
        # Use optimized dashboard function for better performance
        from dashboard_optimized import get_optimized_dashboard_data
        
        template_data = get_optimized_dashboard_data(
            current_user, selected_date, selected_user_id, 
            ist, db, User, Lead, get_initial_followup_count
        )
        
        # Cache the results for 5 minutes
        dashboard_cache_store[(current_user.id, selected_date, selected_user_id)] = template_data
        
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
            'completed_followups': 0,
            'USER_MOBILE_MAPPING': USER_MOBILE_MAPPING
        }
        
        return render_template('dashboard.html', **emergency_data)

@application.route('/api/dashboard/status-update', methods=['POST'])
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

@application.route('/api/dashboard/quick-followup', methods=['POST'])
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

@application.route('/api/trigger-snapshot', methods=['POST'])
@login_required
def trigger_manual_snapshot():
    """Manual trigger for daily snapshot - useful for testing or emergency fixes"""
    if not current_user.is_admin:
        return jsonify({'success': False, 'message': 'Admin access required'})
    
    try:
        with application.app_context():
            capture_daily_snapshot()
        return jsonify({'success': True, 'message': 'Daily snapshot completed successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'})

@application.route('/init_db', methods=['GET'])
def initialize_database():
    # Allow database initialization in production for initial setup
    try:
        with application.app_context():
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

@application.route('/api/user-followup-numbers/<int:user_id>')
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

@application.route('/test_db')
def test_database():
    """Test database connection and show configuration status"""
    try:
        # Test the database connection with proper SQLAlchemy syntax
        result = db.session.execute(db.text('SELECT version()')).fetchone()
        db_version = result[0] if result else 'Unknown'
        
        # Get table count
        table_count = db.session.execute(db.text("""
            SELECT COUNT(*) 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """)).fetchone()[0]
        
        # Test data queries
        user_count = User.query.count()
        lead_count = Lead.query.count()
        
        return f"""
        <h2>🎉 AWS RDS Database Connection Successful!</h2>
        <h3>Database Info:</h3>
        <ul>
            <li><strong>Database Version:</strong> {db_version}</li>
            <li><strong>Tables in Database:</strong> {table_count}</li>
            <li><strong>Users:</strong> {user_count}</li>
            <li><strong>Leads:</strong> {lead_count}</li>
        </ul>
        
        <h3>Connection Details:</h3>
        <ul>
            <li><strong>Database URL:</strong> {application.config['SQLALCHEMY_DATABASE_URI'][:50]}...</li>
            <li><strong>Pool Size:</strong> {application.config.get('SQLALCHEMY_ENGINE_OPTIONS', {}).get('pool_size', 'Default')}</li>
            <li><strong>SSL Mode:</strong> Not Required (AWS RDS)</li>
        </ul>
        
        <h3>Available Tables:</h3>
        <ul>
            <li>✅ Users table</li>
            <li>✅ Leads table</li>
            <li>✅ Daily Followup Count table</li>
        </ul>
        
        <p><a href="/dashboard">← Back to Dashboard</a></p>
        """
    except Exception as e:
        return f"""
        <h2>❌ Database Connection Failed</h2>
        <p><strong>Error:</strong> {str(e)}</p>
        
        <h3>Troubleshooting:</h3>
        <ol>
            <li>Check your AWS RDS credentials in environment variables</li>
            <li>Ensure your RDS instance is running</li>
            <li>Verify network connectivity and security groups</li>
            <li>Check if database tables exist</li>
        </ol>
        
        <h3>Current Configuration:</h3>
        <ul>
            <li><strong>Database URL:</strong> {application.config.get('SQLALCHEMY_DATABASE_URI', 'Not set')[:50]}...</li>
            <li><strong>Environment:</strong> {os.getenv('FLASK_ENV', 'development')}</li>
        </ul>
        
        <p><a href="/init_db">Initialize Database</a> | <a href="/dashboard">Dashboard</a></p>
        """

@application.route('/db_inspect')
@login_required
def inspect_database():
    """Comprehensive database inspection endpoint"""
    if not current_user.is_admin:
        return "Admin access required", 403
    
    try:
        inspect_data = {
            'database_info': {},
            'tables': {},
            'sample_data': {},
            'schema_info': {}
        }
        
        # Database version and basic info
        result = db.session.execute(db.text('SELECT version()')).fetchone()
        inspect_data['database_info']['version'] = result[0] if result else 'Unknown'
        
        # Current database name
        result = db.session.execute(db.text('SELECT current_database()')).fetchone()
        inspect_data['database_info']['database_name'] = result[0] if result else 'Unknown'
        
        # Table information
        tables_query = db.text("""
            SELECT table_name, table_type 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
            ORDER BY table_name
        """)
        tables = db.session.execute(tables_query).fetchall()
        
        for table in tables:
            table_name = table[0]
            inspect_data['tables'][table_name] = {
                'type': table[1],
                'columns': [],
                'row_count': 0
            }
            
            # Get column information
            columns_query = db.text("""
                SELECT column_name, data_type, is_nullable, column_default
                FROM information_schema.columns 
                WHERE table_schema = 'public' AND table_name = :table_name
                ORDER BY ordinal_position
            """)
            columns = db.session.execute(columns_query, {'table_name': table_name}).fetchall()
            
            for col in columns:
                inspect_data['tables'][table_name]['columns'].append({
                    'name': col[0],
                    'type': col[1],
                    'nullable': col[2],
                    'default': col[3]
                })
            
            # Get row count
            try:
                count_query = db.text(f'SELECT COUNT(*) FROM "{table_name}"')
                count_result = db.session.execute(count_query).fetchone()
                inspect_data['tables'][table_name]['row_count'] = count_result[0] if count_result else 0
            except:
                inspect_data['tables'][table_name]['row_count'] = 'Error counting'
        
        # Sample data from main tables
        main_tables = ['user', 'lead', 'dailyfollowupcount']
        for table_name in main_tables:
            if table_name in inspect_data['tables']:
                try:
                    sample_query = db.text(f'SELECT * FROM "{table_name}" LIMIT 5')
                    sample_results = db.session.execute(sample_query).fetchall()
                    
                    # Convert to list of dictionaries
                    if sample_results:
                        columns = [col['name'] for col in inspect_data['tables'][table_name]['columns']]
                        inspect_data['sample_data'][table_name] = []
                        for row in sample_results:
                            row_dict = {}
                            for i, col in enumerate(columns):
                                row_dict[col] = str(row[i]) if row[i] is not None else 'NULL'
                            inspect_data['sample_data'][table_name].append(row_dict)
                except Exception as e:
                    inspect_data['sample_data'][table_name] = f'Error: {str(e)}'
        
        # Database size and statistics
        try:
            size_query = db.text("""
                SELECT pg_size_pretty(pg_database_size(current_database())) as size
            """)
            size_result = db.session.execute(size_query).fetchone()
            inspect_data['database_info']['size'] = size_result[0] if size_result else 'Unknown'
        except:
            inspect_data['database_info']['size'] = 'Unknown'
        
        # Format as HTML for easy viewing
        html_output = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Database Inspection - GaadiMech CRM</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .section {{ margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }}
                .table {{ border-collapse: collapse; width: 100%; margin: 10px 0; }}
                .table th, .table td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
                .table th {{ background-color: #f2f2f2; }}
                .code {{ background-color: #f5f5f5; padding: 10px; border-radius: 3px; }}
                .error {{ color: red; }}
                .success {{ color: green; }}
            </style>
        </head>
        <body>
            <h1>🔍 Database Inspection - GaadiMech CRM</h1>
            
            <div class="section">
                <h2>📊 Database Information</h2>
                <div class="code">
                    <strong>Database:</strong> {inspect_data['database_info'].get('database_name', 'Unknown')}<br>
                    <strong>Version:</strong> {inspect_data['database_info'].get('version', 'Unknown')}<br>
                    <strong>Size:</strong> {inspect_data['database_info'].get('size', 'Unknown')}<br>
                    <strong>Connection URL:</strong> {application.config['SQLALCHEMY_DATABASE_URI'][:50]}...
                </div>
            </div>
            
            <div class="section">
                <h2>🗂️ Tables Overview</h2>
                <table class="table">
                    <tr>
                        <th>Table Name</th>
                        <th>Type</th>
                        <th>Columns</th>
                        <th>Row Count</th>
                    </tr>
        """
        
        for table_name, table_info in inspect_data['tables'].items():
            html_output += f"""
                    <tr>
                        <td><strong>{table_name}</strong></td>
                        <td>{table_info['type']}</td>
                        <td>{len(table_info['columns'])}</td>
                        <td>{table_info['row_count']}</td>
                    </tr>
            """
        
        html_output += """
                </table>
            </div>
        """
        
        # Table schemas
        for table_name, table_info in inspect_data['tables'].items():
            html_output += f"""
            <div class="section">
                <h3>📋 Table: {table_name}</h3>
                <table class="table">
                    <tr>
                        <th>Column</th>
                        <th>Type</th>
                        <th>Nullable</th>
                        <th>Default</th>
                    </tr>
            """
            
            for col in table_info['columns']:
                html_output += f"""
                    <tr>
                        <td><strong>{col['name']}</strong></td>
                        <td>{col['type']}</td>
                        <td>{col['nullable']}</td>
                        <td>{col['default'] or 'None'}</td>
                    </tr>
                """
            
            html_output += "</table>"
            
            # Sample data
            if table_name in inspect_data['sample_data']:
                sample_data = inspect_data['sample_data'][table_name]
                if isinstance(sample_data, list) and sample_data:
                    html_output += f"""
                    <h4>📄 Sample Data (First 5 rows):</h4>
                    <table class="table">
                        <tr>
                    """
                    # Headers
                    for key in sample_data[0].keys():
                        html_output += f"<th>{key}</th>"
                    html_output += "</tr>"
                    
                    # Data rows
                    for row in sample_data:
                        html_output += "<tr>"
                        for value in row.values():
                            html_output += f"<td>{value}</td>"
                        html_output += "</tr>"
                    html_output += "</table>"
                else:
                    html_output += f"<p><em>No sample data or error: {sample_data}</em></p>"
            
            html_output += "</div>"
        
        html_output += """
            <div class="section">
                <h2>🔗 Quick Links</h2>
                <p>
                    <a href="/dashboard">← Back to Dashboard</a> |
                    <a href="/test_db">Test DB Connection</a> |
                    <a href="/health">Health Check</a>
                </p>
            </div>
        </body>
        </html>
        """
        
        return html_output
        
    except Exception as e:
        return f"""
        <h2>❌ Database Inspection Failed</h2>
        <p><strong>Error:</strong> {str(e)}</p>
        <p><a href="/dashboard">← Back to Dashboard</a></p>
        """

@application.route('/health')
def health_check():
    """Simple health check endpoint"""
    try:
        # Test database connection
        db.session.execute(db.text('SELECT 1')).fetchone()
        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'environment': os.getenv('FLASK_ENV', 'development')
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e),
            'environment': os.getenv('FLASK_ENV', 'development')
        }), 500

@application.route('/db_test_simple')
def simple_db_test():
    """Simple database test without authentication - for deployment testing"""
    try:
        # Test basic connection
        result = db.session.execute(db.text('SELECT 1 as test')).fetchone()
        
        # Test if tables exist
        tables_exist = {}
        try:
            user_count = User.query.count()
            tables_exist['users'] = f"{user_count} users"
        except:
            tables_exist['users'] = "Table not found"
            
        try:
            lead_count = Lead.query.count()
            tables_exist['leads'] = f"{lead_count} leads"
        except:
            tables_exist['leads'] = "Table not found"
        
        return jsonify({
            'status': 'success',
            'database_connection': 'OK',
            'test_query': str(result[0]) if result else 'No result',
            'tables': tables_exist,
            'database_url': 'Connected to ' + os.getenv('DATABASE_URL', 'Not set')[:50] + '...'
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e),
            'database_url': os.getenv('DATABASE_URL', 'Not set')[:50] + '...'
        }), 500

@application.route('/create_users', methods=['GET'])
def create_users():
    """Create specific users: admin and surakshit"""
    try:
        with application.app_context():
            # Create all tables first
            db.create_all()
            
            users_created = []
            
            # Create admin user (with admin privileges)
            admin = User.query.filter_by(username='admin').first()
            if not admin:
                admin = User(
                    username='admin',
                    name='Administrator',
                    is_admin=True
                )
                admin.set_password('admin123')
                db.session.add(admin)
                users_created.append('admin (Administrator)')
            else:
                # Update existing admin user to ensure correct password
                admin.set_password('admin123')
                admin.is_admin = True
                users_created.append('admin (updated)')
            
            # Create surakshit user
            surakshit = User.query.filter_by(username='surakshit').first()
            if not surakshit:
                surakshit = User(
                    username='surakshit',
                    name='Surakshit Soni',
                    is_admin=False
                )
                surakshit.set_password('surakshit123')
                db.session.add(surakshit)
                users_created.append('surakshit (Surakshit Soni)')
            else:
                # Update existing surakshit user to ensure correct password
                surakshit.set_password('surakshit123')
                users_created.append('surakshit (updated)')
            
            db.session.commit()
            
            # Get all users to display
            all_users = User.query.all()
            
            return f"""
            <h2>✅ Users Created/Updated Successfully!</h2>
            
            <h3>Created/Updated Users:</h3>
            <ul>
                {''.join([f'<li>{user}</li>' for user in users_created])}
            </ul>
            
            <h3>All Users in Database:</h3>
            <table border="1" style="border-collapse: collapse; width: 100%;">
                <tr>
                    <th style="padding: 8px;">ID</th>
                    <th style="padding: 8px;">Username</th>
                    <th style="padding: 8px;">Name</th>
                    <th style="padding: 8px;">Admin</th>
                </tr>
                {''.join([f'''
                <tr>
                    <td style="padding: 8px;">{user.id}</td>
                    <td style="padding: 8px;"><strong>{user.username}</strong></td>
                    <td style="padding: 8px;">{user.name}</td>
                    <td style="padding: 8px;">{"✅ Yes" if user.is_admin else "❌ No"}</td>
                </tr>
                ''' for user in all_users])}
            </table>
            
            <h3>Login Credentials:</h3>
            <div style="background-color: #f0f0f0; padding: 15px; border-radius: 5px;">
                <p><strong>👤 Admin User:</strong><br>
                Username: <code>admin</code><br>
                Password: <code>admin123</code><br>
                Role: Administrator (Full Access)</p>
                
                <p><strong>👤 Surakshit User:</strong><br>
                Username: <code>surakshit</code><br>
                Password: <code>surakshit123</code><br>
                Role: Regular User</p>
            </div>
            
            <h3>🔗 Quick Actions:</h3>
            <p>
                <a href="/login" style="background-color: #007bff; color: white; padding: 10px 15px; text-decoration: none; border-radius: 5px;">🔑 Login Page</a>
                <a href="/dashboard" style="background-color: #28a745; color: white; padding: 10px 15px; text-decoration: none; border-radius: 5px; margin-left: 10px;">📊 Dashboard</a>
                <a href="/db_inspect" style="background-color: #17a2b8; color: white; padding: 10px 15px; text-decoration: none; border-radius: 5px; margin-left: 10px;">🔍 Database Inspector</a>
            </p>
            
            <p><em>You can now login with either of these accounts!</em></p>
            """, 200
            
    except Exception as e:
        db.session.rollback()
        error_message = f"Error creating users: {str(e)}"
        print(error_message)  # Log the error
        return f"""
        <h2>❌ Error Creating Users</h2>
        <p><strong>Error:</strong> {error_message}</p>
        <p><a href="/init_db">Try Database Initialization</a></p>
        """, 500

# Error handlers
@application.errorhandler(404)
def not_found_error(error):
    return render_template('error.html', error="404 - Page Not Found"), 404

@application.errorhandler(500)
def internal_error(error):
    db.session.rollback()  # In case of database error
    return render_template('error.html', error="500 - Internal Server Error"), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    
    # Initialize the scheduler for daily snapshots only in production
    if os.environ.get('FLASK_ENV') != 'development':
        with application.app_context():
            setup_scheduler()
            
            # Run initial snapshot if needed
            try:
                capture_daily_snapshot()
            except Exception as e:
                print(f"Initial snapshot failed: {e}")
    
    # Run in production mode for AWS
    application.run(host='0.0.0.0', port=port, debug=False)
