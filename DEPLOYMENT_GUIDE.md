# GaadiMech CRM v2.0 - Deployment Guide

**Version:** 2.0  
**Date:** November 30, 2025  
**Critical:** Contains security fixes - Deploy ASAP

---

## ⚠️ Pre-Deployment Checklist

### 1. Backup Everything
```bash
# Backup database
pg_dump -h your-host -U your-user -d gaadimech_crm > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup current code
cd /home/user/webapp
tar -czf backup_code_$(date +%Y%m%d).tar.gz --exclude='node_modules' --exclude='.git' .

# Store backups safely
mv backup_*.sql /path/to/safe/location/
mv backup_*.tar.gz /path/to/safe/location/
```

### 2. Prerequisites Check
```bash
# Check Python version (should be 3.8+)
python --version

# Check PostgreSQL version
psql --version

# Check disk space (need at least 1GB free)
df -h

# Check current application status
ps aux | grep application.py
```

---

## 🚀 Deployment Steps

### Step 1: Stop Current Application
```bash
cd /home/user/webapp

# If using systemd
sudo systemctl stop gaadimech-crm

# OR if running manually
pkill -f application.py

# Verify stopped
ps aux | grep application.py  # Should show no results
```

### Step 2: Pull Latest Code
```bash
# Make sure you're on main branch
git branch

# Pull latest changes
git pull origin main

# Verify you have the new features
git log --oneline -1
# Should show: "Implement 6 critical CRM features..."
```

### Step 3: Install Dependencies
```bash
# Activate virtual environment
source venv/bin/activate

# Update packages
pip install -r requirements.txt

# Verify werkzeug is installed (for password hashing)
pip list | grep -i werkzeug
```

### Step 4: Run Database Migrations ⚠️ CRITICAL

This step will:
- Re-hash all existing passwords (one-time only)
- Create new tables (Template, LeadScore, CallLog)
- Add performance indexes

```bash
# Set database URL if not in .env
export DATABASE_URL="postgresql://user:pass@host:port/dbname"

# Run migration
flask db upgrade

# Verify migration succeeded
flask db current
# Should show: 001_security_features

# Check new tables exist
psql $DATABASE_URL -c "\dt" | grep -E "template|lead_score|call_log"
```

### Step 5: Verify Database Changes
```bash
# Check templates were created
psql $DATABASE_URL -c "SELECT COUNT(*) FROM template;"
# Should show: 10

# Check indexes were added
psql $DATABASE_URL -c "
SELECT indexname FROM pg_indexes 
WHERE tablename = 'lead' 
AND indexname LIKE 'idx_%';"
# Should show multiple indexes

# Verify password hashing (check one user)
psql $DATABASE_URL -c "
SELECT username, LENGTH(password_hash) as hash_length, 
  LEFT(password_hash, 10) as hash_preview 
FROM \"user\" LIMIT 1;"
# hash_length should be ~60-100 characters
# hash_preview should start with $2b$ (bcrypt)
```

### Step 6: Update Environment Variables
```bash
# Edit .env file
nano .env

# Add/Update these variables:
FLASK_ENV=production
FORCE_HTTPS=true  # Enable in production with HTTPS
SECRET_KEY=your-long-random-secret-key-here

# Save and exit (Ctrl+X, Y, Enter)

# Verify .env file
cat .env | grep -E "FLASK_ENV|FORCE_HTTPS"
```

### Step 7: Test Database Connection
```bash
# Quick test script
python <<EOF
from application import application, db, User
with application.app_context():
    try:
        # Test connection
        db.session.execute(db.text('SELECT 1'))
        print("✅ Database connection: OK")
        
        # Test user login
        user = User.query.first()
        if user:
            print(f"✅ User table accessible: {user.username}")
            # Test password hashing
            if user.password_hash.startswith('$2b$'):
                print("✅ Password hashing: OK")
            else:
                print("❌ Password hashing: FAILED")
        
        # Test new tables
        from application import Template, LeadScore, CallLog
        templates = Template.query.count()
        print(f"✅ Templates table: {templates} templates found")
        
    except Exception as e:
        print(f"❌ Error: {e}")
EOF
```

### Step 8: Start Application
```bash
# If using systemd
sudo systemctl start gaadimech-crm
sudo systemctl status gaadimech-crm

# OR start manually
nohup python application.py > app.log 2>&1 &

# Verify started
ps aux | grep application.py
tail -f app.log  # Watch for errors
```

### Step 9: Verify Application is Running
```bash
# Check if port is listening (default: 5000)
netstat -tulpn | grep 5000
# OR
lsof -i :5000

# Test HTTP response
curl -I http://localhost:5000
# Should return: HTTP/1.1 200 OK or 302 redirect

# Test login page loads
curl http://localhost:5000/login | grep -i "login"
```

### Step 10: Test New Features

#### Test 1: Login (Password Hashing)
```bash
# Try logging in with existing credentials
# Should work exactly as before
```

#### Test 2: Templates API
```bash
# Test templates endpoint
curl -s http://localhost:5000/api/templates \
  -H "Cookie: session=your-session-cookie" | jq .

# Should return JSON with 10 templates
```

#### Test 3: Calling Queue
```bash
# Access calling queue page
curl -I http://localhost:5000/calling-queue
# Should return 200 OK
```

#### Test 4: Analytics
```bash
# Access analytics page
curl -I http://localhost:5000/analytics
# Should return 200 OK
```

---

## 🧪 Post-Deployment Testing

### Manual Testing Checklist

#### Authentication
- [ ] Login with existing user credentials
- [ ] Verify session persists
- [ ] Logout works
- [ ] Invalid password is rejected

#### Templates
- [ ] Navigate to a lead
- [ ] Open quick-log modal
- [ ] See template dropdown
- [ ] Select a template
- [ ] Content fills in remarks
- [ ] Can edit template content
- [ ] Save works

#### Quick-Log
- [ ] Click "Quick Log" on any lead
- [ ] Modal opens quickly
- [ ] Status buttons work (one-click)
- [ ] Follow-up date selector works
- [ ] Remarks textarea works
- [ ] Voice input button appears (Chrome/Edge)
- [ ] Save button works
- [ ] Keyboard shortcuts work (Alt+Q, Alt+S)

#### Calling Queue
- [ ] Access /calling-queue
- [ ] Loads prioritized leads
- [ ] See high/medium/low priority badges
- [ ] Current lead displays full details
- [ ] "Next Lead" button works instantly
- [ ] "Skip" button moves lead to end
- [ ] Quick-log opens from queue
- [ ] WhatsApp button works
- [ ] Keyboard shortcuts work (N, S, Q, C, W)
- [ ] Queue count updates correctly

#### Voice-to-Text
- [ ] Microphone button visible (Chrome/Edge/Safari)
- [ ] Click button grants permission
- [ ] Speak test phrase
- [ ] Text appears in textarea
- [ ] Can edit transcribed text

#### Analytics
- [ ] Access /analytics
- [ ] Conversion funnel displays
- [ ] Status pie chart renders
- [ ] Daily trend chart renders
- [ ] Call analytics show (if data exists)
- [ ] Team performance table (admin only)
- [ ] Date range filtering works
- [ ] User filtering works (admin only)

#### Performance
- [ ] Dashboard loads in <2 seconds
- [ ] Search is fast (<500ms)
- [ ] No console errors
- [ ] No Python exceptions in logs

---

## 🐛 Troubleshooting

### Issue: "Invalid username or password" after migration

**Cause:** Migration failed to rehash passwords

**Solution:**
```bash
# Check if passwords are hashed
psql $DATABASE_URL -c "SELECT username, password_hash FROM \"user\" LIMIT 1;"

# If password_hash doesn't start with $2b$, run migration again
flask db downgrade
flask db upgrade
```

### Issue: Templates not loading

**Cause:** Default templates not inserted

**Solution:**
```sql
-- Manually insert templates
psql $DATABASE_URL <<EOF
INSERT INTO template (title, content, category, is_global, created_by, usage_count, created_at)
SELECT 
    'Customer Interested', 
    'Customer is interested in the service. Will follow up on [date].', 
    'Interested', 
    true, 
    (SELECT id FROM "user" WHERE is_admin = true LIMIT 1),
    0, 
    NOW()
WHERE NOT EXISTS (SELECT 1 FROM template WHERE title = 'Customer Interested');
-- Repeat for other templates
EOF
```

### Issue: Calling queue empty

**Cause:** No leads scheduled for today, or scoring not calculated

**Solution:**
```python
# Verify leads exist
python <<EOF
from application import application, db, Lead
from datetime import datetime
import pytz

with application.app_context():
    today = datetime.now(pytz.timezone('Asia/Kolkata')).date()
    count = Lead.query.filter(
        db.func.date(Lead.followup_date) == today
    ).count()
    print(f"Leads for today: {count}")
EOF

# If leads exist but queue empty, check scoring function
# Look for errors in app.log
```

### Issue: Voice input not working

**Cause:** Browser doesn't support Web Speech API

**Solution:**
- Use Chrome, Edge, or Safari
- Ensure HTTPS is enabled (required by some browsers)
- Check browser console for errors
- Grant microphone permission

### Issue: Slow performance after migration

**Cause:** Indexes not created properly

**Solution:**
```bash
# Verify indexes exist
psql $DATABASE_URL <<EOF
SELECT 
    tablename, 
    indexname, 
    indexdef 
FROM pg_indexes 
WHERE tablename IN ('lead', 'lead_score', 'call_log', 'template')
ORDER BY tablename, indexname;
EOF

# If missing, run migration again
flask db upgrade
```

### Issue: Application won't start

**Check logs:**
```bash
# Systemd logs
sudo journalctl -u gaadimech-crm -n 50

# Application logs
tail -50 /path/to/app.log

# Python errors
python application.py
# (Look for import errors, syntax errors)
```

**Common causes:**
1. Missing dependencies: `pip install -r requirements.txt`
2. Database connection failed: Check DATABASE_URL
3. Port already in use: `lsof -i :5000` and kill process
4. Syntax errors: Check Python version compatibility

---

## 📊 Monitoring

### Key Metrics to Watch

**First 24 Hours:**
- Login success rate (should be 100%)
- Page load times (dashboard <2s)
- Error rate (should be <1%)
- Quick-log usage vs traditional edit
- Calling queue adoption rate

**First Week:**
- Leads called per day per user
- Average time per lead
- Template usage frequency
- Completion rate improvement
- User feedback

### Log Monitoring Commands

```bash
# Watch application logs
tail -f /path/to/app.log

# Count errors
grep -i error /path/to/app.log | wc -l

# Most common errors
grep -i error /path/to/app.log | sort | uniq -c | sort -rn | head -10

# Check database connections
psql $DATABASE_URL -c "
SELECT count(*) as active_connections 
FROM pg_stat_activity 
WHERE datname = 'gaadimech_crm';"

# Query performance
psql $DATABASE_URL -c "
SELECT query, calls, mean_exec_time, max_exec_time 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 10;"
```

---

## 🔄 Rollback Plan

If critical issues occur, follow these steps:

### Step 1: Stop Application
```bash
sudo systemctl stop gaadimech-crm
# OR
pkill -f application.py
```

### Step 2: Restore Database
```bash
# Restore from backup
psql $DATABASE_URL < backup_YYYYMMDD_HHMMSS.sql
```

### Step 3: Restore Code
```bash
cd /home/user/webapp
git reset --hard HEAD~1  # Go back one commit
# OR
tar -xzf backup_code_YYYYMMDD.tar.gz
```

### Step 4: Restart Application
```bash
sudo systemctl start gaadimech-crm
```

### Step 5: Verify Rollback
```bash
# Check application version
git log --oneline -1

# Test login
curl -I http://localhost:5000/login
```

---

## 📞 Support Contacts

**Technical Issues:**
- Check logs first
- Review troubleshooting section
- Document exact error messages

**Emergency Rollback:**
- Follow rollback plan above
- Document reason for rollback
- Schedule redeployment

---

## ✅ Deployment Success Criteria

Deployment is successful when:
- [ ] All users can login with existing passwords
- [ ] Dashboard loads without errors
- [ ] Calling queue page loads
- [ ] Analytics page loads
- [ ] Templates are available
- [ ] Quick-log works on any lead
- [ ] No critical errors in logs
- [ ] Performance is same or better
- [ ] Database indexes created
- [ ] All tests pass

---

## 📝 Post-Deployment Tasks

### Day 1
- [ ] Monitor error logs continuously
- [ ] Gather user feedback
- [ ] Document any issues
- [ ] Verify all features working

### Week 1
- [ ] Analyze usage metrics
- [ ] Compare performance vs baseline
- [ ] Calculate actual time savings
- [ ] Identify training needs

### Month 1
- [ ] Calculate ROI
- [ ] Review conversion rate changes
- [ ] Optimize based on usage patterns
- [ ] Plan next phase enhancements

---

## 🎯 Next Steps (Phase 2)

After successful deployment and stabilization, consider:

1. **Click-to-Call Integration** (Twilio/Exotel)
2. **WhatsApp Business API** (bulk messaging)
3. **Mobile PWA** (offline support)
4. **Enhanced AI** (better lead scoring with ML)
5. **Workflow Automation** (auto follow-ups)

---

**Document Version:** 1.0  
**Last Updated:** November 30, 2025
**Deployment Status:** Ready for Production
