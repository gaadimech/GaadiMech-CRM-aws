from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
import re
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

if app.config['SQLALCHEMY_DATABASE_URI'].startswith('postgres://'):
    app.config['SQLALCHEMY_DATABASE_URI'] = app.config['SQLALCHEMY_DATABASE_URI'].replace('postgres://', 'postgresql://')

from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
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
    customer_name = db.Column(db.String(100), nullable=False)  # Changed from 'user' to 'customer_name'
    mobile = db.Column(db.String(12), nullable=False)
    followup_date = db.Column(db.DateTime, nullable=False)
    remarks = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    creator_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user = User.query.filter_by(username=username).first()
        
        if user and user.check_password(password):
            login_user(user)
            return redirect(url_for('index'))
        else:
            flash('Invalid username or password', 'error')
    
    return render_template('login.html')

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
    # Format the mobile number (remove any non-digit characters and ensure proper format)
    cleaned_mobile = ''.join(filter(str.isdigit, mobile))
    if len(cleaned_mobile) == 10:  # If it's a 10-digit number, add country code
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
def add_lead():
    customer_name = request.form.get('customer_name')  # Updated from 'user'
    mobile = request.form.get('mobile')
    followup_date = request.form.get('followup_date')
    remarks = request.form.get('remarks')

    if not re.match(r'^\d{10}$|^\d{12}$', mobile):
        flash('Mobile number must be either 10 or 12 digits', 'error')
        return redirect(url_for('index'))

    followup_date = datetime.strptime(followup_date, '%Y-%m-%d')

    new_lead = Lead(
        customer_name=customer_name,  # Updated from 'user'
        mobile=mobile,
        followup_date=followup_date,
        remarks=remarks,
        creator_id=current_user.id
    )
    
    db.session.add(new_lead)
    db.session.commit()
    
    flash('Lead added successfully!', 'success')
    return redirect(url_for('index'))

@app.route('/followups')
@login_required
def followups():
    # Get team members only if user is admin
    team_members = User.query.all() if current_user.is_admin else []
    
    selected_member_id = request.args.get('team_member_id', '')
    date = request.args.get('date', '')
    
    query = Lead.query
    
    if current_user.is_admin:
        # Admin can filter by team member
        if selected_member_id:
            query = query.filter(Lead.creator_id == selected_member_id)
    else:
        # Non-admin users can only see their own leads
        query = query.filter(Lead.creator_id == current_user.id)
    
    if date:
        selected_date = datetime.strptime(date, '%Y-%m-%d')
        query = query.filter(db.func.date(Lead.followup_date) == selected_date.date())
    
    followups = query.order_by(Lead.followup_date.desc()).all()
    return render_template('followups.html', 
                         followups=followups, 
                         team_members=team_members,
                         selected_member_id=selected_member_id)

@app.route('/edit_lead/<int:lead_id>', methods=['GET', 'POST'])
@login_required
def edit_lead(lead_id):
    lead = Lead.query.get_or_404(lead_id)
    
    # Check if user has permission to edit
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

@app.route('/delete_lead/<int:lead_id>', methods=['POST'])
@login_required
def delete_lead(lead_id):
    lead = Lead.query.get_or_404(lead_id)
    
    # Check if user has permission to delete
    if not current_user.is_admin and lead.creator_id != current_user.id:
        return jsonify({'success': False, 'message': 'Permission denied'})
        
    db.session.delete(lead)
    db.session.commit()
    return jsonify({'success': True})


def init_db():
    # Remove the existing database file if it exists
    if os.path.exists('instance/crm.db'):
        os.remove('instance/crm.db')
    
    with app.app_context():
        # Create all tables
        db.create_all()
        
        # Create admin user
        admin = User(
            username='admin',
            name='Administrator',
            is_admin=True
        )
        admin.set_password('admin123')  # Change this in production!
        db.session.add(admin)
        
        # Create some test users
        test_user = User(
            username='test_user',
            name='Test User',
            is_admin=False
        )
        test_user.set_password('test123')
        db.session.add(test_user)
        db.session.commit()
        

        

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))