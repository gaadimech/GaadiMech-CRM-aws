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
from flask_migrate import Migrate
from pytz import timezone
import pytz
from sqlalchemy import text

# Load environment variables
load_dotenv()

# Try to import text_parser with fallback
try:
    from text_parser import parse_customer_text
except ImportError:
    def parse_customer_text(text):
        return {"error": "Text parser not available"}

application = Flask(__name__)
application.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'GaadiMech2024!')

# Database configuration with better error handling
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    # Fallback to individual environment variables
    RDS_HOST = os.getenv("RDS_HOST", "crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
    RDS_DB = os.getenv("RDS_DB", "crmportal")
    RDS_USER = os.getenv("RDS_USER", "crmadmin")
    RDS_PASSWORD = os.getenv("RDS_PASSWORD", "GaadiMech2024!")
    RDS_PORT = os.getenv("RDS_PORT", "5432")
    
    DATABASE_URL = f"postgresql+psycopg2://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"

# Handle postgres:// to postgresql+psycopg2:// conversion
if DATABASE_URL and DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+psycopg2://", 1)

print(f"Database URL configured: {DATABASE_URL[:50]}...")

application.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
application.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# AWS optimized database settings
application.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 5,
    'pool_recycle': 1800,
    'pool_pre_ping': True,
    'connect_args': {
        'connect_timeout': 30,
        'sslmode': 'prefer'
    }
}

# Session configuration
application.config.update(
    SESSION_COOKIE_SECURE=False,
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
    REMEMBER_COOKIE_SECURE=False,
    REMEMBER_COOKIE_HTTPONLY=True,
    REMEMBER_COOKIE_DURATION=timedelta(hours=24),
    PERMANENT_SESSION_LIFETIME=timedelta(hours=24)
)

# Initialize extensions
db = SQLAlchemy(application)
migrate = Migrate(application, db)
login_manager = LoginManager()
login_manager.init_app(application)
login_manager.login_view = 'login'
login_manager.session_protection = "basic"
login_manager.refresh_view = "login"
login_manager.needs_refresh_message = "Please login again to confirm your identity"
login_manager.needs_refresh_message_category = "info"

# Simple cache
dashboard_cache_store = {}

# Configure rate limiter with fallback
try:
    limiter = Limiter(
        key_func=get_remote_address,
        app=application,
        storage_uri="memory://"
    )
except Exception as e:
    print(f"Rate limiter initialization failed: {e}")
    # Create a dummy limiter for deployment
    class DummyLimiter:
        def limit(self, *args, **kwargs):
            def decorator(f):
                return f
            return decorator
    limiter = DummyLimiter()

# Timezone
ist = timezone('Asia/Kolkata')

# Mobile mapping
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
    mobile = db.Column(db.String(15), nullable=False)
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

class UnassignedLead(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    mobile = db.Column(db.String(15), nullable=False)
    customer_name = db.Column(db.String(100), nullable=True)
    car_manufacturer = db.Column(db.String(50), nullable=True)
    car_model = db.Column(db.String(50), nullable=True)
    pickup_type = db.Column(db.String(20), nullable=True)  # 'Pickup' or 'Self Walkin'
    service_type = db.Column(db.String(50), nullable=True)
    scheduled_date = db.Column(db.DateTime, nullable=True)
    source = db.Column(db.String(30), nullable=True)  # 'WhatsApp', 'Chatbot', 'Website', 'Social Media'
    remarks = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(ist))
    created_by = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    
    # Relationship to team assignments
    assignments = db.relationship('TeamAssignment', backref='unassigned_lead', lazy=True)

    __table_args__ = (
        db.CheckConstraint(
            pickup_type.in_(['Pickup', 'Self Walkin']),
            name='valid_pickup_type'
        ),
        db.CheckConstraint(
            service_type.in_(['Express Car Service', 'Dent Paint', 'AC Service', 'Car Wash', 'Repairs']),
            name='valid_service_type'
        ),
        db.CheckConstraint(
            source.in_(['WhatsApp', 'Chatbot', 'Website', 'Social Media']),
            name='valid_source'
        ),
    )

class TeamAssignment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    unassigned_lead_id = db.Column(db.Integer, db.ForeignKey('unassigned_lead.id'), nullable=False)
    assigned_to_user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    assigned_date = db.Column(db.Date, nullable=False)
    assigned_at = db.Column(db.DateTime, default=lambda: datetime.now(ist))
    assigned_by = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    status = db.Column(db.String(20), nullable=False, default='Assigned')
    processed_at = db.Column(db.DateTime, nullable=True)
    added_to_crm = db.Column(db.Boolean, default=False)
    
    # Relationships
    assigned_to = db.relationship('User', foreign_keys=[assigned_to_user_id], backref='assigned_leads')
    assigned_by_user = db.relationship('User', foreign_keys=[assigned_by])

    __table_args__ = (
        db.CheckConstraint(
            status.in_(['Assigned', 'Contacted', 'Added to CRM', 'Ignored']),
            name='valid_assignment_status'
        ),
    )

class WorkedLead(db.Model):
    """
    Tracks when a lead has been worked upon by recording followup date changes.
    This is used to calculate completion rates and track user performance.
    """
    id = db.Column(db.Integer, primary_key=True)
    lead_id = db.Column(db.Integer, db.ForeignKey('lead.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    work_date = db.Column(db.Date, nullable=False)  # Date when the work was done
    old_followup_date = db.Column(db.DateTime, nullable=True)  # Previous followup date
    new_followup_date = db.Column(db.DateTime, nullable=False)  # New followup date
    worked_at = db.Column(db.DateTime, default=lambda: datetime.now(ist))
    
    # Relationships
    lead = db.relationship('Lead', backref='worked_entries')
    user = db.relationship('User', backref='worked_leads')
    
    __table_args__ = (
        db.UniqueConstraint('lead_id', 'user_id', 'work_date', name='unique_worked_lead_per_day'),
    )

@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))

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

@application.before_request
def before_request():
    """Ensure database connection is active"""
    try:
        db.session.execute(text('SELECT 1'))
    except Exception:
        db.session.rollback()
        raise

@application.teardown_request
def teardown_request(exception=None):
    """Ensure proper cleanup after each request"""
    if exception:
        db.session.rollback()
    db.session.remove()

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

def record_worked_lead(lead_id, user_id, old_followup_date, new_followup_date):
    """
    Record when a lead has been worked upon by changing its followup date.
    This is used to track completion rates and user performance.
    """
    try:
        # Get today's date in IST
        today = datetime.now(ist).date()
        
        # Check if we already have a record for this lead on this day
        existing_record = WorkedLead.query.filter_by(
            lead_id=lead_id,
            user_id=user_id,
            work_date=today
        ).first()
        
        if not existing_record:
            # Create new worked lead record
            worked_lead = WorkedLead(
                lead_id=lead_id,
                user_id=user_id,
                work_date=today,
                old_followup_date=old_followup_date,
                new_followup_date=new_followup_date,
                worked_at=datetime.now(ist)
            )
            db.session.add(worked_lead)
            db.session.commit()
            print(f"Recorded worked lead: Lead {lead_id} by User {user_id} on {today}")
        else:
            # Update existing record with new followup date
            existing_record.new_followup_date = new_followup_date
            existing_record.worked_at = datetime.now(ist)
            db.session.commit()
            print(f"Updated worked lead: Lead {lead_id} by User {user_id} on {today}")
        
    except Exception as e:
        print(f"Error recording worked lead: {e}")
        db.session.rollback()

def get_worked_leads_for_date(user_id, date):
    """
    Get the count of worked leads for a specific user on a specific date.
    """
    try:
        worked_count = WorkedLead.query.filter_by(
            user_id=user_id,
            work_date=date
        ).count()
        return worked_count
    except Exception as e:
        print(f"Error getting worked leads count: {e}")
        return 0

def calculate_completion_rate(initial_count, worked_count):
    """
    Calculate completion rate as a percentage.
    """
    if initial_count == 0:
        return 0
    return round((worked_count / initial_count) * 100, 1)

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

        # Clean mobile number first
        mobile = re.sub(r'[^\d]', '', mobile)
        if len(mobile) not in [10, 12]:
            flash('Mobile number must be 10 or 12 digits only', 'error')
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
            # Store old followup date for tracking
            old_followup_date = lead.followup_date
            
            lead.customer_name = request.form.get('customer_name')
            lead.mobile = request.form.get('mobile')
            lead.car_registration = request.form.get('car_registration')
            lead.remarks = request.form.get('remarks')
            lead.status = request.form.get('status')
            
            # Handle followup date
            followup_date = datetime.strptime(request.form.get('followup_date'), '%Y-%m-%d')
            new_followup_date = ist.localize(followup_date)
            lead.followup_date = new_followup_date
            lead.modified_at = datetime.now(ist)
            
            db.session.commit()
            
            # Record that this lead has been worked upon only if followup date changed
            if old_followup_date != new_followup_date:
                record_worked_lead(lead.id, current_user.id, old_followup_date, new_followup_date)
            
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
        
        # Store old followup date for tracking
        old_followup_date = lead.followup_date
        
        # Update followup date
        followup_datetime = datetime.strptime(followup_date, '%Y-%m-%d')
        new_followup_date = ist.localize(followup_datetime)
        lead.followup_date = new_followup_date
        if remarks:
            lead.remarks = remarks
        lead.modified_at = datetime.now(ist)
        
        db.session.commit()
        
        # Record that this lead has been worked upon
        record_worked_lead(lead_id, current_user.id, old_followup_date, new_followup_date)
        
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

@application.route('/api/export-mobile-numbers', methods=['GET'])
@login_required
def export_mobile_numbers():
    """Export mobile numbers based on followup date and team member filters"""
    try:
        # Get query parameters
        selected_date = request.args.get('date', datetime.now(ist).strftime('%Y-%m-%d'))
        selected_user_id = request.args.get('user_id', '')
        
        # Parse the selected date
        target_date = datetime.strptime(selected_date, '%Y-%m-%d').date()
        target_start = ist.localize(datetime.combine(target_date, datetime.min.time()))
        target_end = target_start + timedelta(days=1)
        
        # Convert to UTC for database queries
        target_start_utc = target_start.astimezone(pytz.UTC)
        target_end_utc = target_end.astimezone(pytz.UTC)
        
        # Build query based on filters
        query = Lead.query.filter(
            Lead.followup_date >= target_start_utc,
            Lead.followup_date < target_end_utc
        )
        
        # Apply user filter if specified
        if current_user.is_admin and selected_user_id:
            try:
                user_id = int(selected_user_id)
                query = query.filter(Lead.creator_id == user_id)
            except ValueError:
                pass  # Invalid user ID, show all
        elif not current_user.is_admin:
            # Non-admin users can only see their own followups
            query = query.filter(Lead.creator_id == current_user.id)
        
        # Get the followups
        followups = query.order_by(Lead.customer_name).all()
        
        # Extract mobile numbers
        mobile_numbers = []
        for followup in followups:
            mobile_numbers.append({
                'mobile': followup.mobile,
                'customer_name': followup.customer_name,
                'car_registration': followup.car_registration or '',
                'status': followup.status,
                'created_by': followup.creator.name if followup.creator else 'Unknown'
            })
        
        # Prepare CSV data
        csv_header = 'Mobile Number,Customer Name,Car Registration,Status,Created By\n'
        csv_data = csv_header
        
        for item in mobile_numbers:
            csv_data += f"{item['mobile']},{item['customer_name']},{item['car_registration']},{item['status']},{item['created_by']}\n"
        
        # Return response
        response = make_response(csv_data)
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = f'attachment; filename=mobile_numbers_{selected_date}.csv'
        
        return response
        
    except Exception as e:
        print(f"Error exporting mobile numbers: {e}")
        return jsonify({'success': False, 'message': f'Error: {str(e)}'})

@application.route('/api/parse-customer-text', methods=['POST'])
@login_required
def parse_customer_text_api():
    """Parse customer information from text messages"""
    try:
        # Check if user is admin
        if not current_user.is_admin:
            return jsonify({'success': False, 'message': 'Access denied. Admin privileges required.'}), 403
        
        # Get the text from request
        data = request.get_json()
        if not data or 'text' not in data:
            return jsonify({'success': False, 'message': 'No text provided'}), 400
        
        text = data['text'].strip()
        if not text:
            return jsonify({'success': False, 'message': 'Empty text provided'}), 400
        
        # Parse the text
        parsed_info = parse_customer_text(text)
        
        # Return the parsed information
        return jsonify({
            'success': True,
            'data': parsed_info,
            'message': 'Text parsed successfully'
        })
        
    except Exception as e:
        print(f"Error parsing customer text: {e}")
        return jsonify({'success': False, 'message': f'Error parsing text: {str(e)}'})

@application.route('/api/user-followup-numbers/<int:user_id>', methods=['GET'])
@login_required
def get_user_followup_numbers(user_id):
    """Get followup numbers for a specific user to send via WhatsApp"""
    try:
        # Check if user is admin
        if not current_user.is_admin:
            return jsonify({'success': False, 'message': 'Access denied. Admin privileges required.'}), 403
        
        # Get the user
        user = User.query.get_or_404(user_id)
        
        # Get user's mobile number from mapping
        user_mobile = USER_MOBILE_MAPPING.get(user.name, None)
        
        if not user_mobile:
            return jsonify({'success': False, 'message': f'No mobile number found for {user.name}'})
        
        # Get today's date
        today = datetime.now(ist).date()
        target_start = ist.localize(datetime.combine(today, datetime.min.time()))
        target_end = target_start + timedelta(days=1)
        target_start_utc = target_start.astimezone(pytz.UTC)
        target_end_utc = target_end.astimezone(pytz.UTC)
        
        # Get user's followups for today
        followups = Lead.query.filter(
            Lead.creator_id == user_id,
            Lead.followup_date >= target_start_utc,
            Lead.followup_date < target_end_utc
        ).order_by(Lead.customer_name).all()
        
        # Format followup data
        followup_data = []
        for followup in followups:
            followup_data.append({
                'customer_name': followup.customer_name,
                'mobile': followup.mobile,
                'car_registration': followup.car_registration or '',
                'status': followup.status,
                'remarks': followup.remarks or ''
            })
        
        return jsonify({
            'success': True,
            'user_name': user.name,
            'user_mobile': user_mobile,
            'total_followups': len(followup_data),
            'followups': followup_data
        })
        
    except Exception as e:
        print(f"Error getting user followup numbers: {e}")
        return jsonify({'success': False, 'message': f'Error: {str(e)}'})

@application.route('/dashboard')
@login_required
def dashboard():
    try:
        # Get query parameters
        selected_date = request.args.get('date', datetime.now(ist).strftime('%Y-%m-%d'))
        selected_user_id = request.args.get('user_id', '')
        
        # Parse the selected date
        try:
            target_date = datetime.strptime(selected_date, '%Y-%m-%d').date()
            target_start = ist.localize(datetime.combine(target_date, datetime.min.time()))
            target_end = target_start + timedelta(days=1)
        except ValueError:
            target_date = datetime.now(ist).date()
            target_start = ist.localize(datetime.combine(target_date, datetime.min.time()))
            target_end = target_start + timedelta(days=1)
            selected_date = target_date.strftime('%Y-%m-%d')
        
        # Convert to UTC for database queries
        target_start_utc = target_start.astimezone(pytz.UTC)
        target_end_utc = target_end.astimezone(pytz.UTC)
        
        # Get users based on permissions
        if current_user.is_admin:
            users = User.query.all()
        else:
            users = [current_user]
            selected_user_id = str(current_user.id)
        
        # Base query setup with user filtering
        base_conditions = []
        if selected_user_id and current_user.is_admin:
            try:
                base_conditions.append(Lead.creator_id == int(selected_user_id))
            except ValueError:
                pass
        elif not current_user.is_admin:
            base_conditions.append(Lead.creator_id == current_user.id)
        
        # Get current followups for the selected date
        current_followups_query = db.session.query(Lead).filter(
            Lead.followup_date >= target_start_utc,
            Lead.followup_date < target_end_utc
        )
        if base_conditions:
            current_followups_query = current_followups_query.filter(*base_conditions)
        
        # Add status ordering
        status_order = db.case(
            (Lead.status == 'Confirmed', 1),
            (Lead.status == 'Open', 2),
            (Lead.status == 'Completed', 3),
            (Lead.status == 'Feedback', 4),
            (Lead.status == 'Needs Followup', 5),
            (Lead.status == 'Did Not Pick Up', 6),
            else_=7
        )
        current_followups = current_followups_query.order_by(status_order, Lead.followup_date.asc()).all()
        
        # Convert followups to IST for display
        for followup in current_followups:
            if followup.followup_date:
                followup.followup_date = utc_to_ist(followup.followup_date)
            if followup.created_at:
                followup.created_at = utc_to_ist(followup.created_at)
            if followup.modified_at:
                followup.modified_at = utc_to_ist(followup.modified_at)
        
        # Get daily leads count
        daily_leads_count_query = db.session.query(db.func.count(Lead.id)).filter(
            Lead.created_at >= target_start_utc,
            Lead.created_at < target_end_utc
        )
        if base_conditions:
            daily_leads_count_query = daily_leads_count_query.filter(*base_conditions)
        
        daily_leads_count = daily_leads_count_query.scalar() or 0
        
        # Get status counts
        status_counts_query = db.session.query(
            Lead.status,
            db.func.count(Lead.id)
        ).group_by(Lead.status)
        
        if base_conditions:
            status_counts_query = status_counts_query.filter(*base_conditions)
        
        status_counts = dict(status_counts_query.all())
        
        # Get total leads count
        total_leads_query = db.session.query(db.func.count(Lead.id))
        if base_conditions:
            total_leads_query = total_leads_query.filter(*base_conditions)
        
        total_leads = total_leads_query.scalar() or 0
        
        # Calculate user performance
        user_performance_list = []
        for user in users:
            # Get user's followups for today
            user_followups = [f for f in current_followups if f.creator_id == user.id]
            
            # Get initial followup count from 5AM snapshot
            initial_count = get_initial_followup_count(user.id, target_date)
            
            # Get worked leads count for today
            worked_count = get_worked_leads_for_date(user.id, target_date)
            
            # Calculate completion rate
            completion_rate = calculate_completion_rate(initial_count, worked_count)
            
            # Calculate pending count
            pending_count = max(0, initial_count - worked_count)
            
            # Get user's total leads
            user_total = db.session.query(db.func.count(Lead.id)).filter(
                Lead.creator_id == user.id
            ).scalar() or 0
            
            # Get user's status counts
            user_status_counts = dict(
                db.session.query(
                    Lead.status,
                    db.func.count(Lead.id)
                ).filter(
                    Lead.creator_id == user.id
                ).group_by(Lead.status).all()
            )
            
            user_performance_list.append({
                'user': user,
                'initial_followups': initial_count,
                'pending_followups': pending_count,
                'worked_followups': worked_count,
                'completion_rate': completion_rate,
                'leads_created': user_total,
                'confirmed': user_status_counts.get('Confirmed', 0),
                'completed': user_status_counts.get('Completed', 0),
                'assigned': initial_count,
                'worked': worked_count,
                'pending': pending_count,
                'new_additions': 0,  # Add missing template variable
                'original_assignment': initial_count  # Add missing template variable
            })
        
        # Sort by completion rate
        user_performance_list.sort(key=lambda x: (x['completion_rate'], x['initial_followups']), reverse=True)
        
        # Calculate overall metrics
        total_initial_count = sum(perf['initial_followups'] for perf in user_performance_list)
        total_worked_count = sum(perf['worked_followups'] for perf in user_performance_list)
        overall_completion_rate = calculate_completion_rate(total_initial_count, total_worked_count)
        
        return render_template('dashboard.html',
            todays_followups=current_followups,
            daily_leads_count=daily_leads_count,
            user_performance=user_performance_list,
            status_counts=status_counts,
            users=users,
            selected_date=selected_date,
            selected_user_id=selected_user_id,
            total_leads=total_leads,
            followup_efficiency=0,
            initial_followups_count=total_initial_count,
            completion_rate=overall_completion_rate,
            completed_followups=total_worked_count,
            current_pending_count=len(current_followups),
            USER_MOBILE_MAPPING=USER_MOBILE_MAPPING
        )
        
    except Exception as e:
        print(f"Dashboard error: {str(e)}")
        flash('Dashboard temporarily unavailable. Please try again.', 'error')
        return redirect(url_for('index'))

@application.route('/api/dashboard/followup/<int:lead_id>', methods=['GET'])
@login_required
def get_followup_details(lead_id):
    try:
        lead = Lead.query.get_or_404(lead_id)
        
        # Check permissions
        if not current_user.is_admin and lead.creator_id != current_user.id:
            return jsonify({'success': False, 'message': 'Permission denied'})
        
        # Convert followup date to IST for display
        followup_date = utc_to_ist(lead.followup_date) if lead.followup_date else None
        
        return jsonify({
            'success': True,
            'customer_name': lead.customer_name,
            'mobile': lead.mobile,
            'car_registration': lead.car_registration,
            'followup_date': followup_date.strftime('%Y-%m-%d') if followup_date else None,
            'status': lead.status,
            'remarks': lead.remarks
        })
        
    except Exception as e:
        print(f"Error fetching followup details: {e}")
        return jsonify({'success': False, 'message': 'Error fetching followup details'})

@application.route('/api/dashboard/update-followup', methods=['POST'])
@login_required
def update_followup():
    try:
        data = request.get_json()
        lead_id = data.get('lead_id')
        customer_name = data.get('customer_name')
        mobile = data.get('mobile')
        car_registration = data.get('car_registration')
        followup_date = data.get('followup_date')
        status = data.get('status')
        remarks = data.get('remarks')
        
        lead = Lead.query.get_or_404(lead_id)
        
        # Check permissions
        if not current_user.is_admin and lead.creator_id != current_user.id:
            return jsonify({'success': False, 'message': 'Permission denied'})
        
        # Store old followup date for tracking
        old_followup_date = lead.followup_date
        
        # Update lead details
        lead.customer_name = customer_name
        lead.mobile = mobile
        lead.car_registration = car_registration
        
        # Update followup date
        followup_datetime = datetime.strptime(followup_date, '%Y-%m-%d')
        new_followup_date = ist.localize(followup_datetime)
        lead.followup_date = new_followup_date
        
        lead.status = status
        lead.remarks = remarks
        lead.modified_at = datetime.now(ist)
        
        db.session.commit()
        
        # Record that this lead has been worked upon if followup date changed
        if old_followup_date != new_followup_date:
            record_worked_lead(lead_id, current_user.id, old_followup_date, new_followup_date)
        
        # Clear any cached queries to ensure dashboard gets fresh data
        db.session.expire_all()
        
        return jsonify({'success': True, 'message': 'Followup updated successfully'})
        
    except Exception as e:
        db.session.rollback()
        print(f"Error updating followup: {e}")
        return jsonify({'success': False, 'message': 'Error updating followup'})

@application.route('/followups')
@login_required
def followups():
    try:
        # Get query parameters with better defaults
        selected_date = request.args.get('date', '')  # Empty means show all
        selected_user_id = request.args.get('user_id', '')
        created_date = request.args.get('created_date', '')
        modified_date = request.args.get('modified_date', '')
        car_registration = request.args.get('car_registration', '')
        mobile = request.args.get('mobile', '')
        status = request.args.get('status', '')
        search = request.args.get('search', '')
        
        # Start with base query
        query = Lead.query
        
        # Apply user filter based on permissions
        if current_user.is_admin and selected_user_id:
            try:
                user_id = int(selected_user_id)
                query = query.filter(Lead.creator_id == user_id)
            except ValueError:
                pass  # Invalid user ID, show all
        elif not current_user.is_admin:
            # Non-admin users can only see their own leads
            query = query.filter(Lead.creator_id == current_user.id)
        
        # Apply date filters
        if selected_date:
            try:
                target_date = datetime.strptime(selected_date, '%Y-%m-%d').date()
                target_start = ist.localize(datetime.combine(target_date, datetime.min.time()))
                target_end = target_start + timedelta(days=1)
                target_start_utc = target_start.astimezone(pytz.UTC)
                target_end_utc = target_end.astimezone(pytz.UTC)
                query = query.filter(
                    Lead.followup_date >= target_start_utc,
                    Lead.followup_date < target_end_utc
                )
            except ValueError:
                pass
        
        if created_date:
            try:
                target_date = datetime.strptime(created_date, '%Y-%m-%d').date()
                target_start = ist.localize(datetime.combine(target_date, datetime.min.time()))
                target_end = target_start + timedelta(days=1)
                target_start_utc = target_start.astimezone(pytz.UTC)
                target_end_utc = target_end.astimezone(pytz.UTC)
                query = query.filter(
                    Lead.created_at >= target_start_utc,
                    Lead.created_at < target_end_utc
                )
            except ValueError:
                pass
        
        if modified_date:
            try:
                target_date = datetime.strptime(modified_date, '%Y-%m-%d').date()
                target_start = ist.localize(datetime.combine(target_date, datetime.min.time()))
                target_end = target_start + timedelta(days=1)
                target_start_utc = target_start.astimezone(pytz.UTC)
                target_end_utc = target_end.astimezone(pytz.UTC)
                query = query.filter(
                    Lead.modified_at >= target_start_utc,
                    Lead.modified_at < target_end_utc
                )
            except ValueError:
                pass
        
        # Apply other filters
        if car_registration:
            query = query.filter(Lead.car_registration.ilike(f'%{car_registration}%'))
        
        if mobile:
            query = query.filter(Lead.mobile.ilike(f'%{mobile}%'))
        
        if status:
            query = query.filter(Lead.status == status)
        
        if search:
            query = query.filter(
                db.or_(
                    Lead.customer_name.ilike(f'%{search}%'),
                    Lead.mobile.ilike(f'%{search}%'),
                    Lead.car_registration.ilike(f'%{search}%'),
                    Lead.remarks.ilike(f'%{search}%')
                )
            )
        
        # Get all users for the dropdown
        users = User.query.all() if current_user.is_admin else [current_user]
        
        # Get the followups with pagination
        page = request.args.get('page', 1, type=int)
        per_page = 100  # Show more results per page to see more leads
        
        followups_pagination = query.order_by(Lead.followup_date.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        # Convert followups to IST for display
        for followup in followups_pagination.items:
            if followup.followup_date:
                followup.followup_date = utc_to_ist(followup.followup_date)
            if followup.created_at:
                followup.created_at = utc_to_ist(followup.created_at)
            if followup.modified_at:
                followup.modified_at = utc_to_ist(followup.modified_at)
        
        return render_template('followups.html',
            followups=followups_pagination.items,
            followups_pagination=followups_pagination,
            users=users,
            selected_date=selected_date,
            selected_user_id=selected_user_id,
            created_date=created_date,
            modified_date=modified_date,
            car_registration=car_registration,
            mobile=mobile,
            status=status,
            search=search,
            USER_MOBILE_MAPPING=USER_MOBILE_MAPPING
        )
        
    except Exception as e:
        print(f"Followups error: {str(e)}")
        flash('Error loading followups. Please try again.', 'error')
        return redirect(url_for('index'))

@application.route('/admin_leads')
@login_required
def admin_leads():
    try:
        # Check if user is admin
        if not current_user.is_admin:
            flash('Access denied. Admin privileges required.', 'error')
            return redirect(url_for('index'))
        
        # Get query parameters
        page = request.args.get('page', 1, type=int)
        search = request.args.get('search', '')
        created_date = request.args.get('created_date', '')
        
        # Base query for unassigned leads
        unassigned_query = UnassignedLead.query
        
        # Apply filters
        if search:
            unassigned_query = unassigned_query.filter(
                db.or_(
                    UnassignedLead.customer_name.ilike(f'%{search}%'),
                    UnassignedLead.mobile.ilike(f'%{search}%'),
                    UnassignedLead.car_manufacturer.ilike(f'%{search}%'),
                    UnassignedLead.car_model.ilike(f'%{search}%')
                )
            )
        
        if created_date:
            try:
                filter_date = datetime.strptime(created_date, '%Y-%m-%d').date()
                start_date = ist.localize(datetime.combine(filter_date, datetime.min.time()))
                end_date = start_date + timedelta(days=1)
                start_date_utc = start_date.astimezone(pytz.UTC)
                end_date_utc = end_date.astimezone(pytz.UTC)
                
                unassigned_query = unassigned_query.filter(
                    UnassignedLead.created_at >= start_date_utc,
                    UnassignedLead.created_at < end_date_utc
                )
            except ValueError:
                pass
        
        # Paginate results
        per_page = 20
        recent_leads_pagination = unassigned_query.order_by(
            UnassignedLead.created_at.desc()
        ).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        # Get all team members for assignment dropdown
        team_members = User.query.filter_by(is_admin=False).all()
        
        # Calculate team summary data
        team_summary = []
        for member in team_members:
            # Get assigned leads count for today
            today = datetime.now(ist).date()
            assigned_count = TeamAssignment.query.filter(
                TeamAssignment.assigned_to_user_id == member.id,
                TeamAssignment.assigned_date == today
            ).count()
            
            # Get CRM leads count for today
            crm_count = Lead.query.filter(
                Lead.creator_id == member.id,
                Lead.created_at >= ist.localize(datetime.combine(today, datetime.min.time())).astimezone(pytz.UTC),
                Lead.created_at < ist.localize(datetime.combine(today + timedelta(days=1), datetime.min.time())).astimezone(pytz.UTC)
            ).count()
            
            team_summary.append({
                'member': member,
                'assigned_count': assigned_count,
                'crm_count': crm_count
            })
        
        return render_template('admin_leads.html',
            recent_leads_pagination=recent_leads_pagination,
            recent_leads=recent_leads_pagination.items,
            team_members=team_members,
            team_summary=team_summary,
            today_date=datetime.now(ist).date().strftime('%Y-%m-%d'),
            search=search,
            created_date=created_date
        )
        
    except Exception as e:
        print(f"Admin leads error: {str(e)}")
        flash('Error loading admin leads. Please try again.', 'error')
        return redirect(url_for('index'))

@application.route('/team_leads')
@login_required
def team_leads():
    try:
        # Get today's date
        today = datetime.now(ist).date()
        
        # Get assignments for current user for today
        assignments_query = TeamAssignment.query.join(
            UnassignedLead,
            TeamAssignment.unassigned_lead_id == UnassignedLead.id
        ).filter(
            TeamAssignment.assigned_to_user_id == current_user.id,
            TeamAssignment.assigned_date == today
        )
        
        # Apply filters
        created_date = request.args.get('created_date', '')
        search = request.args.get('search', '')
        
        if created_date:
            try:
                filter_date = datetime.strptime(created_date, '%Y-%m-%d').date()
                assignments_query = assignments_query.filter(
                    TeamAssignment.assigned_date == filter_date
                )
            except ValueError:
                pass
        
        if search:
            assignments_query = assignments_query.filter(
                db.or_(
                    UnassignedLead.customer_name.ilike(f'%{search}%'),
                    UnassignedLead.car_manufacturer.ilike(f'%{search}%'),
                    UnassignedLead.car_model.ilike(f'%{search}%')
                )
            )
        
        # Add options to load the unassigned_lead relationship eagerly
        assignments_query = assignments_query.options(
            db.joinedload(TeamAssignment.unassigned_lead)
        )
        
        assignments = assignments_query.order_by(TeamAssignment.assigned_at.desc()).all()
        
        return render_template('team_leads.html',
            assignments=assignments,
            today=today,
            search=search,
            created_date=created_date
        )
        
    except Exception as e:
        print(f"Team leads error: {str(e)}")
        flash('Error loading team leads. Please try again.', 'error')
        return redirect(url_for('index'))

@application.route('/edit_unassigned_lead/<int:lead_id>', methods=['GET', 'POST'])
@login_required
def edit_unassigned_lead(lead_id):
    try:
        # Check if user is admin
        if not current_user.is_admin:
            flash('Access denied. Admin privileges required.', 'error')
            return redirect(url_for('index'))
        
        lead = UnassignedLead.query.get_or_404(lead_id)
        
        if request.method == 'POST':
            # Update lead details
            lead.customer_name = request.form.get('customer_name')
            lead.mobile = request.form.get('mobile')
            lead.car_manufacturer = request.form.get('car_manufacturer')
            lead.car_model = request.form.get('car_model')
            lead.pickup_type = request.form.get('pickup_type')
            lead.service_type = request.form.get('service_type')
            lead.source = request.form.get('source')
            lead.remarks = request.form.get('remarks')
            
            # Handle scheduled date
            scheduled_date = request.form.get('scheduled_date')
            if scheduled_date:
                lead.scheduled_date = ist.localize(datetime.strptime(scheduled_date, '%Y-%m-%d'))
            
            # Handle team assignment
            assign_to = request.form.get('assign_to')
            if assign_to:
                # Convert to int since form data comes as string
                assign_to = int(assign_to)
                
                # Check if there's an existing assignment for today
                today = datetime.now(ist).date()
                existing_assignment = TeamAssignment.query.filter(
                    TeamAssignment.unassigned_lead_id == lead.id,
                    TeamAssignment.assigned_date == today
                ).first()
                
                if existing_assignment:
                    if existing_assignment.assigned_to_user_id != assign_to:
                        # Update existing assignment
                        existing_assignment.assigned_to_user_id = assign_to
                        existing_assignment.assigned_at = datetime.now(ist)
                        existing_assignment.assigned_by = current_user.id
                        existing_assignment.status = 'Assigned'  # Reset status for new assignment
                        flash('Lead reassigned successfully!', 'success')
                else:
                    # Create new assignment
                    new_assignment = TeamAssignment(
                        unassigned_lead_id=lead.id,
                        assigned_to_user_id=assign_to,
                        assigned_date=today,
                        assigned_at=datetime.now(ist),
                        assigned_by=current_user.id,
                        status='Assigned'
                    )
                    db.session.add(new_assignment)
                    flash('Lead assigned successfully!', 'success')
            else:
                # If no team member selected, remove today's assignment if it exists
                today = datetime.now(ist).date()
                existing_assignment = TeamAssignment.query.filter(
                    TeamAssignment.unassigned_lead_id == lead.id,
                    TeamAssignment.assigned_date == today
                ).first()
                
                if existing_assignment:
                    db.session.delete(existing_assignment)
                    flash('Lead unassigned successfully!', 'success')
            
            db.session.commit()
            return redirect(url_for('admin_leads'))
        
        # Get team members for assignment dropdown
        team_members = User.query.filter_by(is_admin=False).all()
        
        # Get current assignment if any
        current_assignment = TeamAssignment.query.filter_by(
            unassigned_lead_id=lead.id
        ).order_by(TeamAssignment.assigned_at.desc()).first()
        
        return render_template('edit_unassigned_lead.html', 
                             lead=lead, 
                             team_members=team_members, 
                             current_assignment=current_assignment)
        
    except Exception as e:
        print(f"Edit unassigned lead error: {str(e)}")
        flash('Error updating lead. Please try again.', 'error')
        return redirect(url_for('admin_leads'))

@application.route('/api/team-leads/assignment/<int:assignment_id>', methods=['GET'])
@login_required
def get_assignment_details(assignment_id):
    try:
        # Get the assignment
        assignment = TeamAssignment.query.get_or_404(assignment_id)
        
        # Check if user has permission to view this assignment
        if assignment.assigned_to_user_id != current_user.id:
            return jsonify({'success': False, 'message': 'Permission denied'})
        
        # Check if already added to CRM
        if assignment.added_to_crm:
            return jsonify({'success': False, 'message': 'This lead has already been added to CRM'})
        
        # Get the unassigned lead data
        unassigned_lead = assignment.unassigned_lead
        
        # Prepare the combined remarks
        combined_remarks = f"Added from team assignment. Original source: {unassigned_lead.source or 'Unknown'}. "
        combined_remarks += f"Service: {unassigned_lead.service_type or 'Not specified'}. "
        combined_remarks += f"Car: {unassigned_lead.car_manufacturer or ''} {unassigned_lead.car_model or ''}. "
        combined_remarks += f"Pickup: {unassigned_lead.pickup_type or 'Not specified'}. "
        combined_remarks += f"Original remarks: {unassigned_lead.remarks or 'None'}"
        
        return jsonify({
            'success': True,
            'customer_name': unassigned_lead.customer_name or 'Unknown Customer',
            'mobile': unassigned_lead.mobile,
            'car_registration': '',  # Default empty, user can edit
            'followup_date': (datetime.now(ist) + timedelta(days=1)).strftime('%Y-%m-%d'),  # Default to tomorrow
            'status': 'Needs Followup',
            'remarks': combined_remarks
        })
        
    except Exception as e:
        print(f"Error fetching assignment details: {e}")
        return jsonify({'success': False, 'message': 'Error fetching assignment details'})

@application.route('/api/team-leads/add-to-crm/<int:assignment_id>', methods=['POST'])
@login_required
def add_to_crm_with_details(assignment_id):
    try:
        data = request.get_json()
        customer_name = data.get('customer_name')
        mobile = data.get('mobile')
        car_registration = data.get('car_registration', '')
        followup_date = data.get('followup_date')
        status = data.get('status', 'Needs Followup')
        remarks = data.get('remarks', '')
        
        # Get the assignment
        assignment = TeamAssignment.query.get_or_404(assignment_id)
        
        # Check if user has permission to add this assignment to CRM
        if assignment.assigned_to_user_id != current_user.id:
            return jsonify({'success': False, 'message': 'Permission denied'})
        
        # Check if already added to CRM
        if assignment.added_to_crm:
            return jsonify({'success': False, 'message': 'This lead has already been added to CRM'})
        
        # Validate required fields
        if not customer_name or not mobile:
            return jsonify({'success': False, 'message': 'Customer Name and Mobile Number are required'})
        
        # Clean mobile number
        mobile = re.sub(r'[^\d]', '', mobile)
        if len(mobile) not in [10, 12]:
            return jsonify({'success': False, 'message': 'Mobile number must be 10 or 12 digits only'})
        
        # Parse followup date
        followup_datetime = datetime.strptime(followup_date, '%Y-%m-%d')
        followup_date_ist = ist.localize(followup_datetime)
        
        # Create a new lead in the main CRM system
        new_lead = Lead(
            customer_name=customer_name,
            mobile=mobile,
            car_registration=car_registration,
            followup_date=followup_date_ist,
            remarks=remarks,
            status=status,
            creator_id=current_user.id,
            created_at=datetime.now(ist),
            modified_at=datetime.now(ist)
        )
        
        # Add the new lead to the database
        db.session.add(new_lead)
        
        # Mark the assignment as added to CRM
        assignment.added_to_crm = True
        assignment.status = 'Added to CRM'
        assignment.processed_at = datetime.now(ist)
        
        # Commit the changes
        db.session.commit()
        
        # Clear any cached queries to ensure fresh data
        db.session.expire_all()
        
        return jsonify({'success': True, 'message': 'Lead successfully added to CRM!'})
        
    except Exception as e:
        db.session.rollback()
        print(f"Error adding to CRM: {str(e)}")
        return jsonify({'success': False, 'message': 'Error adding lead to CRM. Please try again.'})

@application.route('/add_to_crm/<int:assignment_id>', methods=['POST'])
@login_required
def add_to_crm(assignment_id):
    try:
        # Get the assignment
        assignment = TeamAssignment.query.get_or_404(assignment_id)
        
        # Check if user has permission to add this assignment to CRM
        if assignment.assigned_to_user_id != current_user.id:
            flash('Access denied. You can only add your own assigned leads to CRM.', 'error')
            return redirect(url_for('team_leads'))
        
        # Check if already added to CRM
        if assignment.added_to_crm:
            flash('This lead has already been added to CRM.', 'info')
            return redirect(url_for('team_leads'))
        
        # Get the unassigned lead data
        unassigned_lead = assignment.unassigned_lead
        
        # Create a new lead in the main CRM system
        new_lead = Lead(
            customer_name=unassigned_lead.customer_name or 'Unknown Customer',
            mobile=unassigned_lead.mobile,
            car_registration='',  # Can be updated later
            followup_date=datetime.now(ist) + timedelta(days=1),  # Default to tomorrow
            remarks=f"Added from team assignment. Original source: {unassigned_lead.source or 'Unknown'}. "
                   f"Service: {unassigned_lead.service_type or 'Not specified'}. "
                   f"Car: {unassigned_lead.car_manufacturer or ''} {unassigned_lead.car_model or ''}. "
                   f"Pickup: {unassigned_lead.pickup_type or 'Not specified'}. "
                   f"Original remarks: {unassigned_lead.remarks or 'None'}",
            status='Needs Followup',
            creator_id=current_user.id,
            created_at=datetime.now(ist),
            modified_at=datetime.now(ist)
        )
        
        # Add the new lead to the database
        db.session.add(new_lead)
        
        # Mark the assignment as added to CRM
        assignment.added_to_crm = True
        assignment.status = 'Added to CRM'
        assignment.processed_at = datetime.now(ist)
        
        # Commit the changes
        db.session.commit()
        
        flash('Lead successfully added to CRM!', 'success')
        
    except Exception as e:
        db.session.rollback()
        print(f"Error adding to CRM: {str(e)}")
        flash('Error adding lead to CRM. Please try again.', 'error')
    
    return redirect(url_for('team_leads'))

# Error handlers
@application.errorhandler(404)
def not_found_error(error):
    return render_template('error.html', error="404 - Page Not Found"), 404

@application.errorhandler(500)
def internal_error(error):
    db.session.rollback()
    return render_template('error.html', error="500 - Internal Server Error"), 500

# Database initialization function
def init_database():
    """Initialize database with tables and default users"""
    try:
        with application.app_context():
            # Create all tables
            db.create_all()
            
            # Check if admin user exists, if not create it
            admin_user = User.query.filter_by(username='admin').first()
            if not admin_user:
                admin_user = User(
                    username='admin',
                    password_hash='admin123',  # Change this in production
                    name='Administrator',
                    is_admin=True
                )
                db.session.add(admin_user)
            
            # Create default users if they don't exist
            default_users = [
                {'username': 'hemlata', 'name': 'Hemlata', 'password': 'hemlata123'},
                {'username': 'sneha', 'name': 'Sneha', 'password': 'sneha123'}
            ]
            
            for user_data in default_users:
                existing_user = User.query.filter_by(username=user_data['username']).first()
                if not existing_user:
                    new_user = User(
                        username=user_data['username'],
                        password_hash=user_data['password'],
                        name=user_data['name'],
                        is_admin=False
                    )
                    db.session.add(new_user)
            
            db.session.commit()
            print("Database initialized successfully")
            
    except Exception as e:
        print(f"Database initialization error: {e}")
        db.session.rollback()

if __name__ == '__main__':
    # Initialize database when application starts
    try:
        init_database()
        print("✅ Database initialized successfully")
    except Exception as e:
        print(f"❌ Failed to initialize database: {e}")
        import traceback
        traceback.print_exc()
    
    port = int(os.environ.get('PORT', 5000))
    print(f"Starting application on port {port}")
    
    # Run without debug mode for better stability
    application.run(host='0.0.0.0', port=port, debug=False) 