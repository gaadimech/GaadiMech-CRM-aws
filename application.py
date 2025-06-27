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

# Debug: Print environment variables
print(f"DEBUG: DATABASE_URL from env: {DATABASE_URL}")
print(f"DEBUG: RDS_HOST from env: {os.getenv('RDS_HOST')}")
print(f"DEBUG: RDS_DB from env: {os.getenv('RDS_DB')}")
print(f"DEBUG: RDS_USER from env: {os.getenv('RDS_USER')}")

# AWS RDS fallback configuration
if not DATABASE_URL:
    RDS_HOST = os.getenv("RDS_HOST", "crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
    RDS_DB = os.getenv("RDS_DB", "postgres")
    RDS_USER = os.getenv("RDS_USER", "crmadmin")
    RDS_PASSWORD = os.getenv("RDS_PASSWORD", "gaadimech123")
    RDS_PORT = os.getenv("RDS_PORT", "5432")
    
    print(f"DEBUG: Using RDS_HOST: {RDS_HOST}")
    print(f"DEBUG: Using RDS_DB: {RDS_DB}")
    print(f"DEBUG: Using RDS_USER: {RDS_USER}")
    
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

# Other routes (simplified for deployment)
@application.route('/followups')
@login_required
def followups():
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
    port = int(os.environ.get('PORT', 5000))
    application.run(host='0.0.0.0', port=port, debug=False) 