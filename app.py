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

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'gaadimech123')  # Provide a default secret key

# Database configuration
# Get DATABASE_URL from environment variable (AWS RDS connection string)
DATABASE_URL = os.getenv("DATABASE_URL")

# Fallback AWS RDS URL if not set in environment
if not DATABASE_URL:
    # Replace these with your actual AWS RDS credentials
    RDS_HOST = os.getenv("RDS_HOST", "gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
    RDS_DB = os.getenv("RDS_DB", "crmportal")
    RDS_USER = os.getenv("RDS_USER", "postgres")
    RDS_PASSWORD = os.getenv("RDS_PASSWORD", "GaadiMech2024!")
    RDS_PORT = os.getenv("RDS_PORT", "5432")
    
    DATABASE_URL = f"postgresql+psycopg2://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"

# Ensure we're using postgresql+psycopg2:// format for psycopg2-binary compatibility
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+psycopg2://", 1)
elif DATABASE_URL.startswith("postgresql://"):
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+psycopg2://", 1)
elif DATABASE_URL.startswith("postgresql+psycopg://"):
    DATABASE_URL = DATABASE_URL.replace("postgresql+psycopg://", "postgresql+psycopg2://", 1)

app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# AWS RDS optimized settings
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 10,
    'pool_recycle': 300,
    'pool_pre_ping': True,
    'connect_args': {
        'sslmode': 'prefer',  # AWS RDS supports SSL but doesn't require it by default
        'connect_timeout': 10
    }
}

# Initialize database and login manager
db = SQLAlchemy(app)
migrate = Migrate(app, db)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Simple in-memory cache for development (avoiding Flask-Caching complexity)
dashboard_cache_store = {}

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
    REMEMBER_COOKIE_DURATION=timedelta(hours=24),
    PERMANENT_SESSION_LIFETIME=timedelta(hours=24)
)

# Update login manager configuration for mobile compatibility
login_manager.session_protection = "basic"  # Changed from "strong" to "basic" for mobile compatibility
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
            # Invalidate cached dashboard data to ensure counts reflect updates from the Followups page
            dashboard_cache_store.clear()
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
        # Clear dashboard cache so removal reflects immediately on the dashboard metrics
        dashboard_cache_store.clear()
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
        
        # Clear cache if switching from Supabase to AWS RDS to avoid stale data
        cache_key = (current_user.id, selected_date, selected_user_id)
        
        # Check cache first for performance (but skip if debug mode for fresh data)
        cached_data = None
        if not app.debug:
            cached_data = dashboard_cache_store.get(cache_key)
        
        if cached_data:
            return render_template('dashboard.html', **cached_data)
        
        # Use optimized dashboard function for better performance
        from dashboard_optimized import get_optimized_dashboard_data
        
        template_data = get_optimized_dashboard_data(
            current_user, selected_date, selected_user_id, 
            ist, db, User, Lead, get_initial_followup_count
        )
        
        # Cache the results for 5 minutes (only in production)
        if not app.debug:
            dashboard_cache_store[cache_key] = template_data
        
        return render_template('dashboard.html', **template_data)
        
    except Exception as e:
        # Clear potentially corrupted cache
        dashboard_cache_store.clear()
        
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
        
        # Clear dashboard cache to reflect changes
        dashboard_cache_store.clear()
        
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
        
        # Clear dashboard cache to reflect changes
        dashboard_cache_store.clear()
        
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

@app.route('/test_db')
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
            <li><strong>Database URL:</strong> {app.config['SQLALCHEMY_DATABASE_URI'][:50]}...</li>
            <li><strong>Pool Size:</strong> {app.config.get('SQLALCHEMY_ENGINE_OPTIONS', {}).get('pool_size', 'Default')}</li>
            <li><strong>SSL Mode:</strong> Prefer (AWS RDS)</li>
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
            <li>Ensure your RDS instance is running and accessible</li>
            <li>Verify network connectivity and security groups</li>
            <li>Check if database tables exist</li>
        </ol>
        
        <h3>Current Configuration:</h3>
        <ul>
            <li><strong>Database URL:</strong> {app.config.get('SQLALCHEMY_DATABASE_URI', 'Not set')[:50]}...</li>
            <li><strong>Environment:</strong> {os.getenv('FLASK_ENV', 'development')}</li>
        </ul>
        
        <p><a href="/init_db">Initialize Database</a> | <a href="/dashboard">Dashboard</a></p>
        """

@app.route('/api/clear-cache', methods=['POST'])
@login_required
def clear_dashboard_cache():
    """Clear dashboard cache - useful after database changes or debugging"""
    if not current_user.is_admin:
        return jsonify({'success': False, 'message': 'Admin access required'})
    
    try:
        dashboard_cache_store.clear()
        return jsonify({'success': True, 'message': 'Dashboard cache cleared successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error clearing cache: {str(e)}'})

@app.route('/health-check')
def health_check():
    """Health check endpoint to verify database connectivity and system status"""
    try:
        # Test database connection
        result = db.session.execute(db.text('SELECT 1')).fetchone()
        db_status = 'connected' if result else 'disconnected'
        
        # Check basic table existence
        try:
            user_count = User.query.count()
            lead_count = Lead.query.count()
            daily_count_records = DailyFollowupCount.query.count()
            tables_status = 'ok'
        except Exception as table_error:
            user_count = lead_count = daily_count_records = 0
            tables_status = f'error: {str(table_error)}'
        
        health_data = {
            'status': 'healthy' if db_status == 'connected' and tables_status == 'ok' else 'unhealthy',
            'database': {
                'status': db_status,
                'type': 'AWS RDS PostgreSQL',
                'tables_status': tables_status,
                'user_count': user_count,
                'lead_count': lead_count,
                'daily_count_records': daily_count_records
            },
            'cache': {
                'size': len(dashboard_cache_store),
                'type': 'in-memory'
            },
            'timestamp': datetime.now(ist).isoformat()
        }
        
        return jsonify(health_data)
        
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now(ist).isoformat()
        }), 500

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
