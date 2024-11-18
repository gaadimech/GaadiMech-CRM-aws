from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
import re
import os
from dotenv import load_dotenv
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address   
from datetime import timedelta


load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-here')  # Provide a default secret key

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
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Configure rate limiter
limiter = Limiter(
    key_func=get_remote_address,
    app=app,
    storage_uri="memory://"
)

# Database Models
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    leads = db.relationship('Lead', backref='creator', lazy=True)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

class Lead(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    customer_name = db.Column(db.String(100), nullable=False)
    mobile = db.Column(db.String(12), nullable=False)
    followup_date = db.Column(db.DateTime, nullable=False)
    remarks = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    creator_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("5 per minute")
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
                response = make_response(redirect(url_for('index')))
                response.set_cookie('session', 
                                 value=request.cookies.get('session'),
                                 secure=True,
                                 httponly=True,
                                 samesite='Lax',
                                 max_age=timedelta(hours=24))
                
                # Get next page from args or default to index
                next_page = request.args.get('next')
                if not next_page or not next_page.startswith('/'):
                    next_page = url_for('index')
                    
                return response
            else:
                flash('Invalid username or password', 'error')
        except Exception as e:
            flash('An error occurred during login. Please try again.', 'error')
            print(f"Login error: {str(e)}")  # Log the error
    
    return render_template('login.html')

app.config.update(
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
    REMEMBER_COOKIE_SECURE=True,
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

@app.route('/add_lead', methods=['POST'])
@login_required
@limiter.limit("30 per minute")
def add_lead():
    try:
        customer_name = request.form.get('customer_name')
        mobile = request.form.get('mobile')
        followup_date = request.form.get('followup_date')
        remarks = request.form.get('remarks')

        if not all([customer_name, mobile, followup_date]):
            flash('All required fields must be filled', 'error')
            return redirect(url_for('index'))

        if not re.match(r'^\d{10}$|^\d{12}$', mobile):
            flash('Mobile number must be either 10 or 12 digits', 'error')
            return redirect(url_for('index'))

        followup_date = datetime.strptime(followup_date, '%Y-%m-%d')

        new_lead = Lead(
            customer_name=customer_name,
            mobile=mobile,
            followup_date=followup_date,
            remarks=remarks,
            creator_id=current_user.id
        )
        
        db.session.add(new_lead)
        db.session.commit()
        
        flash('Lead added successfully!', 'success')
    except Exception as e:
        db.session.rollback()
        flash('Error adding lead. Please try again.', 'error')
        print(f"Error adding lead: {str(e)}")  # Log the error
    
    return redirect(url_for('index'))

@app.route('/followups')
@login_required
def followups():
    try:
        team_members = User.query.all() if current_user.is_admin else []
        selected_member_id = request.args.get('team_member_id', '')
        date = request.args.get('date', '')
        
        query = Lead.query
        
        if current_user.is_admin:
            if selected_member_id:
                query = query.filter(Lead.creator_id == selected_member_id)
        else:
            query = query.filter(Lead.creator_id == current_user.id)
        
        if date:
            selected_date = datetime.strptime(date, '%Y-%m-%d')
            query = query.filter(db.func.date(Lead.followup_date) == selected_date.date())
        
        followups = query.order_by(Lead.followup_date.desc()).all()
        return render_template('followups.html', 
                             followups=followups, 
                             team_members=team_members,
                             selected_member_id=selected_member_id)
    except Exception as e:
        flash('Error loading followups. Please try again.', 'error')
        print(f"Error loading followups: {str(e)}")  # Log the error
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
            lead.followup_date = datetime.strptime(request.form['followup_date'], '%Y-%m-%d')
            lead.remarks = request.form['remarks']
            db.session.commit()
            flash('Lead updated successfully!', 'success')
            return redirect(url_for('followups'))
        
        return render_template('edit_lead.html', lead=lead)
    except Exception as e:
        db.session.rollback()
        flash('Error updating lead. Please try again.', 'error')
        print(f"Error updating lead: {str(e)}")  # Log the error
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

@app.route('/init_db', methods=['GET'])
def initialize_database():
    if not os.getenv('ALLOW_DB_INIT', '').lower() == 'true':
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
    app.run(host='0.0.0.0', port=port)