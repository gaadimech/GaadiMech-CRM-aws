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
application.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'GaadiMech2024!')

# Database configuration for AWS RDS with auto-detection of psycopg version
DATABASE_URL = os.getenv("DATABASE_URL")

# AWS RDS fallback configuration
if not DATABASE_URL:
    RDS_HOST = os.getenv("RDS_HOST", "gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
    RDS_DB = os.getenv("RDS_DB", "crmportal")
    RDS_USER = os.getenv("RDS_USER", "postgres")
    RDS_PASSWORD = os.getenv("RDS_PASSWORD", "GaadiMech2024!")
    RDS_PORT = os.getenv("RDS_PORT", "5432")
    
    # Try psycopg3 first, fallback to psycopg2
    try:
        import psycopg
        DATABASE_URL = f"postgresql+psycopg://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"
        print("Using psycopg3 (psycopg) driver")
    except ImportError:
        try:
            import psycopg2
            DATABASE_URL = f"postgresql+psycopg2://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"
            print("Using psycopg2 driver")
        except ImportError:
            # Fallback to basic postgresql
            DATABASE_URL = f"postgresql://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"
            print("Using basic PostgreSQL driver")

# Ensure proper format based on what's available
if DATABASE_URL:
    if DATABASE_URL.startswith("postgres://"):
        # Try to upgrade to psycopg if available
        try:
            import psycopg
            DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+psycopg://", 1)
        except ImportError:
            try:
                import psycopg2
                DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+psycopg2://", 1)
            except ImportError:
                DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

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

# Simple in-memory cache for development
dashboard_cache_store = {}

print(f"Database connected using: {DATABASE_URL[:50]}...")

# Configure rate limiter
limiter = Limiter(
    key_func=get_remote_address,
    app=application,
    storage_uri="memory://"
)

# Get IST timezone
ist = timezone('Asia/Kolkata')

# Mobile number mapping for team members
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
        self.password_hash = password

    def check_password(self, password):
        return self.password_hash == password

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
        
        try:
            user = User.query.filter_by(username=username).first()
            
            if user and user.check_password(password):
                login_user(user, remember=True)
                next_page = request.args.get('next')
                if not next_page or not next_page.startswith('/'):
                    next_page = url_for('index')
                return redirect(next_page)
            else:
                flash('Invalid username or password', 'error')
        except Exception as e:
            flash('An error occurred during login. Please try again.', 'error')
            print(f"Login error: {str(e)}")
    
    return render_template('login.html')

# Session configuration
application.config.update(
    SESSION_COOKIE_SECURE=application.config.get('PREFERRED_URL_SCHEME') == 'https',
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
    REMEMBER_COOKIE_SECURE=application.config.get('PREFERRED_URL_SCHEME') == 'https',
    REMEMBER_COOKIE_HTTPONLY=True,
    REMEMBER_COOKIE_DURATION=timedelta(hours=24),
    PERMANENT_SESSION_LIFETIME=timedelta(hours=24)
)

login_manager.session_protection = "basic"
login_manager.refresh_view = "login"
login_manager.needs_refresh_message = "Please login again to confirm your identity"
login_manager.needs_refresh_message_category = "info"

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
    ist_tz = pytz.timezone('Asia/Kolkata')
    return utc_dt.astimezone(ist_tz)

def get_initial_followup_count(user_id, date):
    daily_count = DailyFollowupCount.query.filter_by(
        user_id=user_id, 
        date=date
    ).first()
    
    if daily_count:
        return daily_count.initial_count
    else:
        start_datetime = datetime.combine(date, time.min)
        end_datetime = datetime.combine(date + timedelta(days=1), time.min)
        
        current_count = Lead.query.filter(
            Lead.creator_id == user_id,
            Lead.followup_date >= start_datetime,
            Lead.followup_date < end_datetime
        ).count()
        
        # Create record
        daily_count = DailyFollowupCount(
            user_id=user_id,
            date=date,
            initial_count=current_count
        )
        try:
            db.session.add(daily_count)
            db.session.commit()
        except:
            db.session.rollback()
        
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
        remarks = request.form.get('remarks')
        status = request.form.get('status')

        if not status or status not in ['Did Not Pick Up', 'Needs Followup', 'Confirmed', 'Open', 'Completed', 'Feedback']:
            status = 'Needs Followup'

        followup_date = datetime.strptime(request.form.get('followup_date'), '%Y-%m-%d')
        followup_date = ist.localize(followup_date)

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
        
        # Clear any cached queries to ensure dashboard gets fresh data
        db.session.expire_all()
        
        flash('Lead added successfully!', 'success')
    except Exception as e:
        db.session.rollback()
        flash('Error adding lead. Please try again.', 'error')
        print(f"Error adding lead: {str(e)}")
    
    return redirect(url_for('index'))

@application.route('/edit_lead/<int:lead_id>', methods=['GET', 'POST'])
@login_required
def edit_lead(lead_id):
    lead = Lead.query.get_or_404(lead_id)
    
    # Check permissions
    if not current_user.is_admin and lead.creator_id != current_user.id:
        flash('Permission denied', 'error')
        return redirect(url_for('followups'))
    
    if request.method == 'POST':
        try:
            lead.customer_name = request.form.get('customer_name')
            lead.mobile = request.form.get('mobile')
            lead.car_registration = request.form.get('car_registration')
            lead.remarks = request.form.get('remarks')
            lead.status = request.form.get('status')
            
            # Handle followup date
            followup_date = datetime.strptime(request.form.get('followup_date'), '%Y-%m-%d')
            lead.followup_date = ist.localize(followup_date)
            lead.modified_at = datetime.now(ist)
            
            db.session.commit()
            
            # Clear any cached queries to ensure dashboard gets fresh data
            db.session.expire_all()
            
            flash('Lead updated successfully!', 'success')
            return redirect(url_for('followups'))
        except Exception as e:
            db.session.rollback()
            flash('Error updating lead', 'error')
            print(f"Error updating lead: {str(e)}")
    
    return render_template('edit_lead.html', lead=lead)

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
        
        # Clear any cached queries to ensure dashboard gets fresh data
        db.session.expire_all()
        
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
        
        # Clear any cached queries to ensure dashboard gets fresh data
        db.session.expire_all()
        
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

@application.route('/dashboard')
@login_required
def dashboard():
    try:
        selected_date = request.args.get('date', datetime.now(ist).strftime('%Y-%m-%d'))
        selected_user_id = request.args.get('user_id', '')
        
        # Use optimized dashboard function
        try:
            from dashboard_optimized import get_optimized_dashboard_data
            template_data = get_optimized_dashboard_data(
                current_user, selected_date, selected_user_id, 
                ist, db, User, Lead, get_initial_followup_count
            )
        except Exception as e:
            print(f"Dashboard optimization error: {e}")
            # Fallback to basic dashboard
            template_data = {
                'todays_followups': [],
                'daily_leads_count': 0,
                'user_performance': [],
                'status_counts': {'Needs Followup': 0},
                'users': [current_user] if current_user.is_authenticated else [],
                'selected_date': selected_date,
                'selected_user_id': selected_user_id,
                'total_leads': 0,
                'followup_efficiency': 0,
                'initial_followups_count': 0,
                'completion_rate': 0,
                'completed_followups': 0,
                'USER_MOBILE_MAPPING': USER_MOBILE_MAPPING
            }
        
        return render_template('dashboard.html', **template_data)
        
    except Exception as e:
        print(f"Dashboard error: {str(e)}")
        flash('Dashboard temporarily unavailable. Please try again.', 'warning')
        return redirect(url_for('index'))

@application.route('/health-check')
def health_check():
    """Health check endpoint for AWS load balancer"""
    try:
        # Test database connection
        result = db.session.execute(db.text('SELECT 1')).fetchone()
        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'timestamp': datetime.now(ist).isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e),
            'timestamp': datetime.now(ist).isoformat()
        }), 500

@application.route('/health')
def health():
    """Simple health endpoint"""
    return "OK", 200

@application.route('/test_db')
def test_database():
    """Test database connection"""
    try:
        result = db.session.execute(db.text('SELECT version()')).fetchone()
        db_version = result[0] if result else 'Unknown'
        
        user_count = User.query.count()
        lead_count = Lead.query.count()
        
        return jsonify({
            'status': 'success',
            'database_version': db_version,
            'user_count': user_count,
            'lead_count': lead_count,
            'connection_url': application.config['SQLALCHEMY_DATABASE_URI'][:50] + '...'
        }), 200
        
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500

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
        mobile = request.args.get('mobile', '')
        status_filter = request.args.get('status', '')
        
        page = request.args.get('page', 1, type=int)
        per_page = 50

        query = Lead.query

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
            start_date = ist.localize(start_date)
            end_date = start_date + timedelta(days=1)
            
            start_date_utc = start_date.astimezone(pytz.UTC)
            end_date_utc = end_date.astimezone(pytz.UTC)
            
            query = query.filter(
                Lead.followup_date >= start_date_utc,
                Lead.followup_date < end_date_utc
            )
        
        if created_date:
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
            
        if mobile:
            query = query.filter(Lead.mobile.ilike(f'%{mobile}%'))
        
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
                             timedelta=timedelta,
                             current_user=current_user,
                             date=date,
                             created_date=created_date,
                             modified_date=modified_date,
                             car_registration=car_registration,
                             mobile=mobile,
                             status_filter=status_filter)
        
    except Exception as e:
        print(f"Followups error: {str(e)}")
        flash('Error loading followups. Please try again.', 'error')
        return render_template('followups.html', followups=[], team_members=[], selected_member_id='', timedelta=timedelta)

# Error handlers
@application.errorhandler(404)
def not_found_error(error):
    return render_template('error.html', error="404 - Page Not Found"), 404

@application.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return render_template('error.html', error="500 - Internal Server Error"), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 3030))
    
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