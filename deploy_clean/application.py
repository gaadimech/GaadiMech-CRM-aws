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

# Database configuration for your existing RDS
DATABASE_URL = os.getenv("DATABASE_URL")

# Your existing RDS configuration
if not DATABASE_URL:
    RDS_HOST = os.getenv("RDS_HOST", "crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
    RDS_DB = os.getenv("RDS_DB", "crmportal")
    RDS_USER = os.getenv("RDS_USER", "postgres")
    RDS_PASSWORD = os.getenv("RDS_PASSWORD", "GaadiMech2024!")
    RDS_PORT = os.getenv("RDS_PORT", "5432")
    
    # Try psycopg2 for compatibility
    try:
        import psycopg2
        DATABASE_URL = f"postgresql+psycopg2://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"
        print("Using psycopg2 driver")
    except ImportError:
        # Fallback to basic postgresql
        DATABASE_URL = f"postgresql://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"
        print("Using basic PostgreSQL driver")

# Ensure proper format
if DATABASE_URL and DATABASE_URL.startswith("postgres://"):
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
    return render_template('index.html')

def utc_to_ist(utc_dt):
    if utc_dt is None:
        return None
    if utc_dt.tzinfo is None:
        utc_dt = utc_dt.replace(tzinfo=pytz.UTC)
    return utc_dt.astimezone(ist)

def get_initial_followup_count(user_id, date):
    """Get or create the initial followup count for a user on a specific date"""
    try:
        daily_count = DailyFollowupCount.query.filter_by(
            user_id=user_id, 
            date=date
        ).first()
        
        if not daily_count:
            # Get count of leads with followup_date on this date
            count = Lead.query.filter(
                Lead.creator_id == user_id,
                db.func.date(Lead.followup_date) == date
            ).count()
            
            # Create the record
            daily_count = DailyFollowupCount(
                user_id=user_id,
                date=date,
                initial_count=count
            )
            db.session.add(daily_count)
            db.session.commit()
            
        return daily_count.initial_count
    except Exception as e:
        print(f"Error getting initial followup count: {str(e)}")
        db.session.rollback()
        return 0

@application.route('/dashboard')
@login_required
def dashboard():
    try:
        # Basic dashboard data
        today = datetime.now(ist).date()
        
        total_leads = Lead.query.filter_by(creator_id=current_user.id).count()
        pending_followups = Lead.query.filter(
            Lead.creator_id == current_user.id,
            Lead.followup_date <= datetime.now(ist),
            Lead.status.in_(['Needs Followup', 'Did Not Pick Up'])
        ).count()
        
        completed_today = Lead.query.filter(
            Lead.creator_id == current_user.id,
            db.func.date(Lead.modified_at) == today,
            Lead.status.in_(['Completed', 'Confirmed'])
        ).count()
        
        return render_template('dashboard.html',
            total_leads=total_leads,
            pending_followups=pending_followups,
            completed_today=completed_today
        )
    except Exception as e:
        print(f"Dashboard error: {str(e)}")
        return render_template('error.html', error="Dashboard temporarily unavailable")

@application.route('/health-check')
def health_check():
    """Comprehensive health check for AWS ALB"""
    try:
        # Test database connection
        db.session.execute(db.text('SELECT 1'))
        db.session.commit()
        
        return jsonify({
            'status': 'healthy',
            'database': 'connected',
            'timestamp': datetime.now(ist).isoformat(),
            'app': 'GaadiMech CRM'
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now(ist).isoformat()
        }), 503

@application.route('/health')
def health():
    return "OK", 200

@application.route('/test_db')
def test_database():
    try:
        # Test database connection
        result = db.session.execute(db.text('SELECT version();'))
        version = result.fetchone()[0]
        
        # Test tables exist
        tables = db.session.execute(db.text("""
            SELECT table_name FROM information_schema.tables 
            WHERE table_schema = 'public'
        """)).fetchall()
        
        return jsonify({
            'status': 'success',
            'database_version': version,
            'tables': [table[0] for table in tables],
            'connection': 'successful'
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500

@application.route('/followups')
@login_required
def followups():
    return render_template('followups.html')

@application.errorhandler(404)
def not_found_error(error):
    return render_template('error.html', error='Page not found'), 404

@application.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return render_template('error.html', error='Internal server error'), 500

if __name__ == '__main__':
    with application.app_context():
        try:
            db.create_all()
            print("Database tables created successfully")
        except Exception as e:
            print(f"Error creating database tables: {str(e)}")
    
    application.run(debug=False, host='0.0.0.0', port=5000) 