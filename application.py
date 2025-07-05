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
from text_parser import parse_customer_text

load_dotenv()

application = Flask(__name__)
application.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'GaadiMech2024!')

# AWS Elastic Beanstalk database configuration
DATABASE_URL = os.getenv("DATABASE_URL")

# AWS RDS configuration with better error handling
if not DATABASE_URL:
    RDS_HOST = os.getenv("RDS_HOST", "gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com")
    RDS_DB = os.getenv("RDS_DB", "crmportal")
    RDS_USER = os.getenv("RDS_USER", "postgres")
    RDS_PASSWORD = os.getenv("RDS_PASSWORD", "GaadiMech2024!")
    RDS_PORT = os.getenv("RDS_PORT", "5432")
    
    DATABASE_URL = f"postgresql+psycopg2://{RDS_USER}:{RDS_PASSWORD}@{RDS_HOST}:{RDS_PORT}/{RDS_DB}"

# Handle postgres:// to postgresql+psycopg2:// conversion
if DATABASE_URL and DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql+psycopg2://", 1)

application.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
application.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# AWS optimized database settings
application.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 3,
    'pool_recycle': 1800,
    'pool_pre_ping': True,
    'connect_args': {
        'connect_timeout': 30,
        'sslmode': 'prefer'
    }
}

# Initialize extensions
db = SQLAlchemy(application)
migrate = Migrate(application, db)
login_manager = LoginManager()
login_manager.init_app(application)
login_manager.login_view = 'login'

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
    SESSION_COOKIE_SECURE=False,  # Set to False for AWS ALB
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
    REMEMBER_COOKIE_SECURE=False,  # Set to False for AWS ALB
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

@application.route('/admin_leads', methods=['GET', 'POST'])
@login_required
def admin_leads():
    if not current_user.is_admin:
        flash('Access denied. Admin privileges required.', 'error')
        return redirect(url_for('index'))
    
    if request.method == 'POST':
        try:
            # Get form data
            mobile = request.form.get('mobile')
            customer_name = request.form.get('customer_name')
            car_manufacturer = request.form.get('car_manufacturer')
            car_model = request.form.get('car_model')
            pickup_type = request.form.get('pickup_type')
            service_type = request.form.get('service_type')
            scheduled_date_str = request.form.get('scheduled_date')
            source = request.form.get('source')
            remarks = request.form.get('remarks')
            assign_to = request.form.get('assign_to')
            
            # Validate mobile number
            if not mobile:
                flash('Mobile number is required.', 'error')
                return redirect(url_for('admin_leads'))
            
            # Validate team member assignment
            if not assign_to:
                flash('Team member assignment is required.', 'error')
                return redirect(url_for('admin_leads'))
            
            # Clean mobile number
            mobile = re.sub(r'[^\d]', '', mobile)
            if len(mobile) not in [10, 12]:
                flash('Mobile number must be 10 or 12 digits only.', 'error')
                return redirect(url_for('admin_leads'))
            
            # Parse scheduled date
            scheduled_date = None
            if scheduled_date_str:
                try:
                    scheduled_date = datetime.strptime(scheduled_date_str, '%Y-%m-%d')
                    scheduled_date = ist.localize(scheduled_date)
                except ValueError:
                    flash('Invalid date format.', 'error')
                    return redirect(url_for('admin_leads'))
            
            # Convert empty strings to None for optional fields with constraints
            pickup_type = pickup_type if pickup_type and pickup_type.strip() else None
            service_type = service_type if service_type and service_type.strip() else None
            source = source if source and source.strip() else None
            customer_name = customer_name if customer_name and customer_name.strip() else None
            car_manufacturer = car_manufacturer if car_manufacturer and car_manufacturer.strip() else None
            car_model = car_model if car_model and car_model.strip() else None
            remarks = remarks if remarks and remarks.strip() else None
            
            # Create new unassigned lead
            new_lead = UnassignedLead(
                mobile=mobile,
                customer_name=customer_name,
                car_manufacturer=car_manufacturer,
                car_model=car_model,
                pickup_type=pickup_type,
                service_type=service_type,
                scheduled_date=scheduled_date,
                source=source,
                remarks=remarks,
                created_by=current_user.id
            )
            
            db.session.add(new_lead)
            db.session.flush()  # Get the ID
            
            # Create team assignment (now mandatory)
            assignment_date = datetime.now(ist).date()
            team_assignment = TeamAssignment(
                unassigned_lead_id=new_lead.id,
                assigned_to_user_id=int(assign_to),
                assigned_date=assignment_date,
                assigned_by=current_user.id
            )
            db.session.add(team_assignment)
            
            db.session.commit()
            
            flash('Lead added successfully!', 'success')
            return redirect(url_for('admin_leads'))
            
        except Exception as e:
            db.session.rollback()
            flash(f'Error adding lead: {str(e)}', 'error')
            return redirect(url_for('admin_leads'))
    
    # Get all team members for assignment dropdown
    team_members = User.query.filter_by(is_admin=False).all()
    
    # Get today's date in IST for default filter
    today_date = datetime.now(ist).strftime('%Y-%m-%d')
    
    # Get recent unassigned leads with filters
    query = UnassignedLead.query
    
    # Apply date filter if provided, default to today if no filter
    created_date = request.args.get('created_date', today_date)
    if created_date:
        try:
            filter_date = datetime.strptime(created_date, '%Y-%m-%d')
            filter_date = ist.localize(filter_date)
            end_date = filter_date + timedelta(days=1)
            
            filter_date_utc = filter_date.astimezone(pytz.UTC)
            end_date_utc = end_date.astimezone(pytz.UTC)
            
            query = query.filter(
                UnassignedLead.created_at >= filter_date_utc,
                UnassignedLead.created_at < end_date_utc
            )
        except ValueError:
            pass  # Invalid date format, ignore filter
    
    # Apply search filter if provided
    search = request.args.get('search')
    if search:
        search_filter = f"%{search}%"
        query = query.filter(
            db.or_(
                UnassignedLead.customer_name.ilike(search_filter),
                UnassignedLead.car_manufacturer.ilike(search_filter),
                UnassignedLead.car_model.ilike(search_filter)
            )
        )
    
    # Get pagination parameters
    page = request.args.get('page', 1, type=int)
    per_page = 5
    
    # Get the filtered results with pagination
    recent_leads_pagination = query.order_by(UnassignedLead.created_at.desc()).paginate(
        page=page, per_page=per_page, error_out=False
    )
    
    # Get team summary for the filtered date
    team_summary = []
    try:
        filter_date_obj = datetime.strptime(created_date, '%Y-%m-%d').date()
        for member in team_members:
            # Count assignments for this member on the filtered date
            assignment_count = TeamAssignment.query.join(UnassignedLead).filter(
                TeamAssignment.assigned_to_user_id == member.id,
                TeamAssignment.assigned_date == filter_date_obj
            ).count()
            
            # Count how many of those have been added to CRM
            crm_count = TeamAssignment.query.join(UnassignedLead).filter(
                TeamAssignment.assigned_to_user_id == member.id,
                TeamAssignment.assigned_date == filter_date_obj,
                TeamAssignment.added_to_crm == True
            ).count()
            
            team_summary.append({
                'member': member,
                'assigned_count': assignment_count,
                'crm_count': crm_count
            })
    except ValueError:
        # If date parsing fails, create empty summary
        for member in team_members:
            team_summary.append({
                'member': member,
                'assigned_count': 0,
                'crm_count': 0
            })
    
    # Sort team summary by assigned_count in descending order
    team_summary.sort(key=lambda x: x['assigned_count'], reverse=True)
    
    return render_template('admin_leads.html', 
                         team_members=team_members,
                         recent_leads=recent_leads_pagination.items,
                         recent_leads_pagination=recent_leads_pagination,
                         team_summary=team_summary,
                         today_date=today_date)

@application.route('/team_leads')
@login_required
def team_leads():
    if current_user.is_admin:
        flash('This page is for team members only.', 'info')
        return redirect(url_for('admin_leads'))
    
    # Get today's date
    today = datetime.now(ist).date()
    
    # Get assignments for current user for today with filters
    query = TeamAssignment.query.filter_by(
        assigned_to_user_id=current_user.id,
        assigned_date=today
    ).join(UnassignedLead)
    
    # Apply date filter if provided (for created date of the unassigned lead)
    created_date = request.args.get('created_date')
    if created_date:
        try:
            filter_date = datetime.strptime(created_date, '%Y-%m-%d')
            filter_date = ist.localize(filter_date)
            end_date = filter_date + timedelta(days=1)
            
            filter_date_utc = filter_date.astimezone(pytz.UTC)
            end_date_utc = end_date.astimezone(pytz.UTC)
            
            query = query.filter(
                UnassignedLead.created_at >= filter_date_utc,
                UnassignedLead.created_at < end_date_utc
            )
        except ValueError:
            pass  # Invalid date format, ignore filter
    
    # Apply search filter if provided
    search = request.args.get('search')
    if search:
        search_filter = f"%{search}%"
        query = query.filter(
            db.or_(
                UnassignedLead.customer_name.ilike(search_filter),
                UnassignedLead.car_manufacturer.ilike(search_filter),
                UnassignedLead.car_model.ilike(search_filter)
            )
        )
    
    # Get the filtered assignments
    assignments = query.all()
    
    return render_template('team_leads.html', assignments=assignments, today=today)

@application.route('/edit_unassigned_lead/<int:lead_id>', methods=['GET', 'POST'])
@login_required
def edit_unassigned_lead(lead_id):
    if not current_user.is_admin:
        flash('Access denied. Admin privileges required.', 'error')
        return redirect(url_for('admin_leads'))
    
    lead = UnassignedLead.query.get_or_404(lead_id)
    
    if request.method == 'POST':
        try:
            # Get form data
            mobile = request.form.get('mobile')
            customer_name = request.form.get('customer_name')
            car_manufacturer = request.form.get('car_manufacturer')
            car_model = request.form.get('car_model')
            pickup_type = request.form.get('pickup_type')
            service_type = request.form.get('service_type')
            scheduled_date_str = request.form.get('scheduled_date')
            source = request.form.get('source')
            remarks = request.form.get('remarks')
            assign_to = request.form.get('assign_to')
            
            # Validate mobile number
            if not mobile:
                flash('Mobile number is required.', 'error')
                team_members = User.query.filter_by(is_admin=False).all()
                current_assignment = TeamAssignment.query.filter_by(unassigned_lead_id=lead.id).first()
                return render_template('edit_unassigned_lead.html', 
                                     lead=lead, 
                                     team_members=team_members,
                                     current_assignment=current_assignment)
            
            # Clean mobile number
            mobile = re.sub(r'[^\d]', '', mobile)
            if len(mobile) not in [10, 12]:
                flash('Mobile number must be 10 or 12 digits only.', 'error')
                team_members = User.query.filter_by(is_admin=False).all()
                current_assignment = TeamAssignment.query.filter_by(unassigned_lead_id=lead.id).first()
                return render_template('edit_unassigned_lead.html', 
                                     lead=lead, 
                                     team_members=team_members,
                                     current_assignment=current_assignment)
            
            # Parse scheduled date
            scheduled_date = None
            if scheduled_date_str:
                try:
                    scheduled_date = datetime.strptime(scheduled_date_str, '%Y-%m-%d')
                    scheduled_date = ist.localize(scheduled_date)
                except ValueError:
                    flash('Invalid date format.', 'error')
                    team_members = User.query.filter_by(is_admin=False).all()
                    current_assignment = TeamAssignment.query.filter_by(unassigned_lead_id=lead.id).first()
                    return render_template('edit_unassigned_lead.html', 
                                         lead=lead, 
                                         team_members=team_members,
                                         current_assignment=current_assignment)
            
            # Convert empty strings to None for optional fields with constraints
            pickup_type = pickup_type if pickup_type and pickup_type.strip() else None
            service_type = service_type if service_type and service_type.strip() else None
            source = source if source and source.strip() else None
            customer_name = customer_name if customer_name and customer_name.strip() else None
            car_manufacturer = car_manufacturer if car_manufacturer and car_manufacturer.strip() else None
            car_model = car_model if car_model and car_model.strip() else None
            remarks = remarks if remarks and remarks.strip() else None
            
            # Update lead
            lead.mobile = mobile
            lead.customer_name = customer_name
            lead.car_manufacturer = car_manufacturer
            lead.car_model = car_model
            lead.pickup_type = pickup_type
            lead.service_type = service_type
            lead.scheduled_date = scheduled_date
            lead.source = source
            lead.remarks = remarks
            
            # Handle team assignment
            current_assignment = TeamAssignment.query.filter_by(unassigned_lead_id=lead.id).first()
            
            if assign_to:
                # Team member is selected
                if current_assignment:
                    # Update existing assignment
                    current_assignment.assigned_to_user_id = int(assign_to)
                    current_assignment.assigned_date = datetime.now(ist).date()
                    current_assignment.assigned_by = current_user.id
                    current_assignment.assigned_at = datetime.now(ist)
                else:
                    # Create new assignment
                    new_assignment = TeamAssignment(
                        unassigned_lead_id=lead.id,
                        assigned_to_user_id=int(assign_to),
                        assigned_date=datetime.now(ist).date(),
                        assigned_by=current_user.id
                    )
                    db.session.add(new_assignment)
            else:
                # No team member selected, remove existing assignment if any
                if current_assignment:
                    db.session.delete(current_assignment)
            
            db.session.commit()
            
            flash('Lead updated successfully!', 'success')
            return redirect(url_for('admin_leads'))
            
        except Exception as e:
            db.session.rollback()
            flash(f'Error updating lead: {str(e)}', 'error')
            # Get current assignment for error page as well
            team_members = User.query.filter_by(is_admin=False).all()
            current_assignment = TeamAssignment.query.filter_by(unassigned_lead_id=lead.id).first()
            return render_template('edit_unassigned_lead.html', 
                                 lead=lead, 
                                 team_members=team_members,
                                 current_assignment=current_assignment)
    
    # Get all team members for assignment dropdown
    team_members = User.query.filter_by(is_admin=False).all()
    
    # Get current assignment for this lead (if any)
    current_assignment = TeamAssignment.query.filter_by(unassigned_lead_id=lead.id).first()
    
    return render_template('edit_unassigned_lead.html', 
                         lead=lead, 
                         team_members=team_members,
                         current_assignment=current_assignment)

@application.route('/add_to_crm/<int:assignment_id>', methods=['POST'])
@login_required
def add_to_crm(assignment_id):
    try:
        # Get the assignment
        assignment = TeamAssignment.query.get_or_404(assignment_id)
        
        # Check if user has permission
        if assignment.assigned_to_user_id != current_user.id:
            flash('You can only add your own assigned leads to CRM.', 'error')
            return redirect(url_for('team_leads'))
        
        # Check if already added
        if assignment.added_to_crm:
            flash('This lead has already been added to CRM.', 'info')
            return redirect(url_for('team_leads'))
        
        unassigned_lead = assignment.unassigned_lead
        
        # Create new lead in main CRM
        new_lead = Lead(
            customer_name=unassigned_lead.customer_name or 'Unknown',
            mobile=unassigned_lead.mobile,
            car_registration='',
            followup_date=datetime.now(ist) + timedelta(days=1),
            remarks=f"Service: {unassigned_lead.service_type}. Source: {unassigned_lead.source}. {unassigned_lead.remarks or ''}",
            creator_id=current_user.id
        )
        
        db.session.add(new_lead)
        
        # Update assignment status
        assignment.status = 'Added to CRM'
        assignment.added_to_crm = True
        assignment.processed_at = datetime.now(ist)
        
        db.session.commit()
        
        flash('Lead successfully added to CRM!', 'success')
        
    except Exception as e:
        db.session.rollback()
        flash(f'Error adding lead to CRM: {str(e)}', 'error')
    
    return redirect(url_for('team_leads'))

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
    port = int(os.environ.get('PORT', 5000))  # Changed to port 5000 for AWS compatibility
    
    # Run in production mode for AWS
    application.run(host='0.0.0.0', port=port, debug=False) 