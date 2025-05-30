# GaadiMech CRM - Supabase Setup Guide

## 🚀 Quick Setup with Supabase

This CRM application now uses **Supabase** as the database backend, providing a robust, scalable PostgreSQL database in the cloud.

### 🔧 Prerequisites

1. **Python 3.10+** (tested with Python 3.13)
2. **Supabase Account** - [Sign up at supabase.com](https://supabase.com)
3. **Virtual Environment** (recommended)

### 📋 Step-by-Step Setup

#### 1. Get Your Supabase Credentials

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Create a new project or select existing one
3. Navigate to **Settings > Database**
4. Find the **Connection string** section
5. Copy the **URI** (should look like this):
   ```
   postgresql://postgres.[your-project-ref]:[your-password]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres
   ```

#### 2. Install Dependencies

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install requirements
pip install -r requirements.txt
```

#### 3. Set Environment Variables

```bash
# Set your Supabase database URL
export DATABASE_URL="postgresql://postgres.[your-project-ref]:[your-password]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres"

# Optional: Create .env file
echo "DATABASE_URL=postgresql://postgres.[your-project-ref]:[your-password]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres" > .env
echo "SECRET_KEY=your_secret_key_here" >> .env
```

#### 4. Initialize Database

```bash
# Run the setup script to create tables and admin user
python setup_supabase.py
```

This will:
- ✅ Create all necessary database tables
- 👤 Create admin user (`admin` / `admin123`)
- 🧪 Create test user (`test_user` / `test123`)
- 🔍 Test the database connection

#### 5. Start the Application

```bash
python app.py
```

Your CRM will be available at: **http://localhost:8080**

### 🔍 Testing the Setup

Visit these URLs to verify everything is working:

- **Main App**: http://localhost:8080
- **Database Test**: http://localhost:8080/test_db
- **Login**: Use `admin` / `admin123`

### 🏗️ Database Configuration

The app is configured with Supabase-optimized settings:

```python
# Connection pooling for performance
'pool_size': 10
'pool_recycle': 300
'pool_pre_ping': True

# SSL required for Supabase
'sslmode': 'require'
'connect_timeout': 10
```

### 🔒 Security Features

- ✅ SSL/TLS encryption (required by Supabase)
- ✅ Connection pooling for performance
- ✅ Session management optimized for mobile
- ✅ Rate limiting for API endpoints
- ✅ Environment variable configuration

### 📱 Mobile-Optimized Features

This CRM is fully optimized for mobile use:

- 📱 Responsive design for all screen sizes
- 🔄 Fixed authentication loops on mobile
- ⚡ Optimized refresh rates (10 min mobile, 5 min desktop)
- 📞 One-tap calling and WhatsApp integration
- 👆 Touch-friendly interface elements

### 🚨 Troubleshooting

#### Connection Issues
```bash
# Test connection manually
python -c "from sqlalchemy import create_engine, text; engine = create_engine('YOUR_DATABASE_URL'); conn = engine.connect(); result = conn.execute(text('SELECT 1')); print('✅ Connection successful!'); conn.close()"
```

#### Common Issues

1. **Invalid credentials**: Check your DATABASE_URL format
2. **Network timeout**: Ensure stable internet connection
3. **SSL errors**: Supabase requires SSL - make sure you're using `postgresql://` not `postgres://`
4. **Python version**: Use Python 3.10+ for best compatibility

#### Environment Variables
```bash
# Check current configuration
python supabase_config.py
```

### 🔄 Migration from Local DB

If migrating from SQLite:

1. Export your existing data
2. Set up Supabase as above
3. Run `setup_supabase.py`
4. Import your data using the admin interface

### 📊 Performance Benefits

**Supabase vs Local SQLite:**
- ✅ Cloud-based - accessible from anywhere
- ✅ Automatic backups and point-in-time recovery
- ✅ Better performance with connection pooling
- ✅ Real-time capabilities (future features)
- ✅ Scalable as your business grows
- ✅ Multi-user support without conflicts

### 🎯 Production Deployment

For production deployment:

1. Use environment variables (never hardcode credentials)
2. Set `FLASK_ENV=production`
3. Use a production WSGI server like Gunicorn
4. Consider using Supabase's connection pooling

```bash
# Production example
gunicorn -w 4 -b 0.0.0.0:8080 app:app
```

### 📞 Support

Having issues? Check:
1. **Supabase Dashboard** - Project status and logs
2. **Network connectivity** - Can you access supabase.com?
3. **Database credentials** - Are they correct and up-to-date?
4. **Python version** - Using 3.10+ recommended

---

**🎉 You're all set!** Your CRM is now powered by Supabase and ready for mobile telecallers to use efficiently. 