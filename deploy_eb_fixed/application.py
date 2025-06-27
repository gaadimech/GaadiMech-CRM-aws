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
    RDS_HOST = os.getenv("RDS_HOST", "crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
    RDS_DB = os.getenv("RDS_DB", "postgres")
    RDS_USER = os.getenv("RDS_USER", "crmadmin")
    RDS_PASSWORD = os.getenv("RDS_PASSWORD", "gaadimech123")
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

print(f"Database connected using: {DATABASE_URL[:50]}...")

# Configure rate limiter
limiter = Limiter(
    key_func=get_remote_address,
    app=application,
    storage_uri="memory://"
)

# Get IST timezone
ist = timezone('Asia/Kolkata')

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
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
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
    return redirect(url_for('dashboard'))

def utc_to_ist(utc_dt):
    """Convert UTC datetime to IST"""
    if utc_dt is None:
        return None
    utc_dt = utc_dt.replace(tzinfo=pytz.UTC)
    ist_dt = utc_dt.astimezone(ist)
    return ist_dt.replace(tzinfo=None)

def get_initial_followup_count(user_id, date):
    """Get initial followup count for a user on a specific date"""
    try:
        # Check if there's already a record for this date and user
        existing_record = DailyFollowupCount.query.filter_by(
            user_id=user_id, 
            date=date
        ).first()
        
        if existing_record:
            return existing_record.initial_count
        
        # Calculate initial count: followups due on or before this date that were created before this date
        count = Lead.query.filter(
            Lead.creator_id == user_id,
            Lead.followup_date <= datetime.combine(date, time.max).replace(tzinfo=ist),
            Lead.created_at < datetime.combine(date, time.min).replace(tzinfo=ist)
        ).count()
        
        return count
    except Exception as e:
        print(f"Error calculating initial followup count: {str(e)}")
        return 0

@application.route('/dashboard')
@login_required  
def dashboard():
    try:
        # Import here to avoid circular import
        from dashboard_optimized import get_optimized_dashboard_data
        
        # Get dashboard data with proper parameters
        selected_date = request.args.get('date', datetime.now(ist).strftime('%Y-%m-%d'))
        selected_user_id = request.args.get('user_id', None)
        
        dashboard_data = get_optimized_dashboard_data(
            current_user, selected_date, selected_user_id, 
            ist, db, User, Lead, get_initial_followup_count
        )
        return render_template('dashboard.html', **dashboard_data)
    except Exception as e:
        print(f"Dashboard error: {str(e)}")
        flash('An error occurred loading the dashboard. Please try again.', 'error')
        return render_template('error.html', 
                             error_message="Dashboard temporarily unavailable",
                             error_details=str(e))

@application.route('/health-check')
def health_check():
    """Simple health check endpoint"""
    try:
        # Test database connection
        db.session.execute(db.text('SELECT 1'))
        db.session.commit()
        
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.now(ist).isoformat(),
            'database': 'connected'
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'timestamp': datetime.now(ist).isoformat(),
            'database': 'disconnected',
            'error': str(e)
        }), 500

@application.route('/health')
def health():
    return "OK", 200

@application.route('/test_db')
def test_database():
    try:
        # Test database connection
        result = db.session.execute(db.text('SELECT version()'))
        version = result.fetchone()[0]
        
        # Test tables exist
        user_count = User.query.count()
        lead_count = Lead.query.count()
        
        return jsonify({
            'status': 'success',
            'database_version': version,
            'user_count': user_count,
            'lead_count': lead_count,
            'timestamp': datetime.now(ist).isoformat()
        })
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e),
            'timestamp': datetime.now(ist).isoformat()
        }), 500

@application.route('/followups')
@login_required
def followups():
    # Simple redirect to dashboard for now since get_followups_data doesn't exist
    return redirect(url_for('dashboard'))

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

@application.errorhandler(404)
def not_found_error(error):
    return render_template('error.html', error_message="Page not found"), 404

@application.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return render_template('error.html', error_message="Internal server error"), 500

# Create tables function
def create_tables():
    """Create database tables if they don't exist"""
    try:
        with application.app_context():
            # Create all tables
            db.create_all()
            print("✅ Database tables created successfully")
            
            # Check if admin user exists, if not create one
            admin_user = User.query.filter_by(username='admin').first()
            if not admin_user:
                admin_user = User(
                    username='admin',
                    password_hash='admin123',  # Change this!
                    name='Admin User',
                    is_admin=True
                )
                db.session.add(admin_user)
                db.session.commit()
                print("✅ Default admin user created (username: admin, password: admin123)")
                
    except Exception as e:
        print(f"❌ Error creating tables: {str(e)}")

# Initialize database on startup if needed
if os.getenv('ALLOW_DB_INIT', 'false').lower() == 'true':
    create_tables()

if __name__ == '__main__':
    application.run(debug=False, host='0.0.0.0', port=int(os.environ.get('PORT', 8080))) 