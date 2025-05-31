# 🚀 Complete AWS Deployment Guide - GaadiMech CRM

**Target Configuration:**
- **Application**: AWS Elastic Beanstalk with t3.micro instances
- **Database**: Amazon RDS PostgreSQL with db.t3.micro
- **Estimated Monthly Cost**: $25-35 for low-medium traffic

---

## 📋 Prerequisites

### 1. **AWS Account Setup**
- Sign up at [aws.amazon.com](https://aws.amazon.com)
- Complete billing setup and account verification
- Note down your AWS Account ID

### 2. **Install AWS CLI Tools**
```bash
# These are already installed in your project
pipx install awsebcli
brew install awscli  # If not already installed
```

### 3. **Configure AWS CLI**
```bash
aws configure
```
**Enter these details:**
- **AWS Access Key ID**: Get from AWS Console → IAM → Users → Security credentials
- **AWS Secret Access Key**: Get from AWS Console → IAM → Users → Security credentials  
- **Default region name**: `ap-south-1` (Mumbai) or your preferred region
- **Default output format**: `json`

---

## 🗄️ Phase 1: Create RDS Database (db.t3.micro)

### Step 1: Navigate to RDS Console
1. Login to [AWS Management Console](https://console.aws.amazon.com)
2. Search for "RDS" in the service search bar
3. Click on "RDS" to open the RDS Dashboard

### Step 2: Create Database
1. Click **"Create database"** button
2. Choose **"Standard create"** method

### Step 3: Engine Configuration
- **Engine type**: ✅ PostgreSQL
- **Edition**: PostgreSQL Community  
- **Version**: PostgreSQL 15.x (latest stable)

### Step 4: Templates
- ✅ **Free tier** (if your account is eligible)
- Or **Dev/Test** (if free tier not available)

### Step 5: Settings
```
DB instance identifier: gaadimech-crm-db
Master username: postgres
Master password: GaadiMech2024!
```

### Step 6: Instance Configuration
```
DB instance class: db.t3.micro ✅
Storage type: General Purpose SSD (gp2)
Allocated storage: 20 GiB
✅ Enable storage autoscaling
Maximum storage threshold: 100 GiB
```

### Step 7: Connectivity
```
VPC: Default VPC
DB subnet group: default
✅ Public access: Yes
VPC security groups: Create new
New VPC security group name: gaadimech-crm-db-sg
Availability Zone: No preference
Database port: 5432
```

### Step 8: Database Authentication
- ✅ **Password authentication**

### Step 9: Additional Configuration
```
Initial database name: crmportal
Backup retention period: 7 days
Backup window: No preference
✅ Enable Enhanced monitoring: No (to save costs)
✅ Enable Performance insights: No (to save costs)
Log exports: None (to save costs)
✅ Enable auto minor version upgrade: Yes
Maintenance window: No preference
✅ Enable deletion protection: No (for development)
```

### Step 10: Create Database
1. Review all settings
2. Click **"Create database"**
3. ⏱️ **Wait 5-10 minutes** for database creation

### Step 11: Note Database Details
Once created, click on your database and note down:
```
Endpoint: gaadimech-crm-db.xxxxxx.ap-south-1.rds.amazonaws.com
Port: 5432
DB Name: crmportal
Username: postgres
Password: GaadiMech2024!
```

---

## 🔒 Phase 2: Configure Security Groups

### Step 1: Navigate to EC2 Security Groups
1. Go to **EC2 Console** → **Security Groups**
2. Find security group: `gaadimech-crm-db-sg`
3. Click on it to select

### Step 2: Edit Inbound Rules
1. Click **"Edit inbound rules"**
2. Click **"Add rule"**
3. Configure:
   ```
   Type: PostgreSQL
   Protocol: TCP
   Port range: 5432
   Source: 0.0.0.0/0 (Allow from anywhere - for initial setup)
   Description: PostgreSQL access for CRM app
   ```
4. Click **"Save rules"**

**⚠️ Security Note**: Later, you can restrict the source to only your Elastic Beanstalk security group for better security.

---

## 🚀 Phase 3: Deploy Application with Elastic Beanstalk

### Step 1: Initialize Elastic Beanstalk

```bash
cd /Users/surakshitsoni/Desktop/GaadiMech-CRM-aws
eb init
```

**Choose these options:**
1. **Region**: `6` (ap-south-1 : Asia Pacific (Mumbai))
2. **Application name**: `gaadimech-crm`
3. **Platform**: `Python 3.11` (or latest available)
4. **Platform branch**: `Python 3.11 running on 64bit Amazon Linux 2023`
5. **CodeCommit**: `N` (No)
6. **SSH keypair**: `Y` (Yes - for debugging access)

### Step 2: Create Environment with t3.micro

```bash
eb create gaadimech-crm-prod --instance-types t3.micro --database.engine postgres --database.instance db.t3.micro
```

**Or create without built-in database (recommended since we already created RDS):**
```bash
eb create gaadimech-crm-prod --instance-types t3.micro
```

**Environment creation prompts:**
- **Environment name**: `gaadimech-crm-prod`
- **DNS CNAME prefix**: `gaadimech-crm-prod` (or choose unique name)
- **Load balancer type**: `Application Load Balancer`

⏱️ **Wait 10-15 minutes** for environment creation.

### Step 3: Set Environment Variables

Replace `YOUR-RDS-ENDPOINT` with your actual RDS endpoint:

```bash
eb setenv SECRET_KEY="GaadiMech-Super-Secret-Key-Change-This-2024"
eb setenv DATABASE_URL="postgresql://postgres:GaadiMech2024!@gaadimech-crm-db.xxxxxx.ap-south-1.rds.amazonaws.com:5432/crmportal"
eb setenv RDS_HOST="gaadimech-crm-db.xxxxxx.ap-south-1.rds.amazonaws.com"
eb setenv RDS_DB="crmportal"
eb setenv RDS_USER="postgres"
eb setenv RDS_PASSWORD="GaadiMech2024!"
eb setenv RDS_PORT="5432"
eb setenv FLASK_ENV="production"
```

### Step 4: Deploy Application

```bash
eb deploy
```

⏱️ **Wait 5-10 minutes** for deployment.

### Step 5: Open Application

```bash
eb open
```

This will open your deployed application in the browser.

---

## 🔧 Phase 4: Database Initialization

### Step 1: SSH into Your Instance
```bash
eb ssh
```

### Step 2: Initialize Database
```bash
# Navigate to application directory
cd /var/app/current

# Activate virtual environment
source /var/app/venv/*/bin/activate

# Run database initialization
python application.py
```

### Step 3: Create Admin User
In your application, navigate to `/init_db` endpoint to initialize the database with default users.

---

## 📊 Phase 5: Configure Application Settings

### Step 1: Environment Configuration
1. Go to **Elastic Beanstalk Console**
2. Select your application: `gaadimech-crm`
3. Select environment: `gaadimech-crm-prod`
4. Go to **Configuration**

### Step 2: Instance Settings
1. Click **"Edit"** next to **Instances**
2. Verify:
   ```
   Instance type: t3.micro ✅
   Security groups: default + custom
   ```

### Step 3: Capacity Settings
1. Click **"Edit"** next to **Capacity**
2. Configure:
   ```
   Environment type: Load balanced
   Min instances: 1
   Max instances: 2
   Fleet composition: On-Demand instances
   Instance types: t3.micro
   ```

### Step 4: Load Balancer Settings
1. Click **"Edit"** next to **Load balancer**
2. Configure:
   ```
   Load balancer type: Application Load Balancer
   Dedicated: No (shared saves cost)
   ```

---

## 💰 Cost Optimization Tips

### 1. **Instance Scheduling (Optional)**
- Consider stopping the environment during non-business hours
- Use `eb terminate` and `eb create` for development environments

### 2. **RDS Cost Optimization**
```
- Use db.t3.micro (free tier eligible)
- Set backup retention to 7 days minimum
- Disable Performance Insights
- Disable Enhanced Monitoring
```

### 3. **Monitoring Costs**
- Check AWS Billing Dashboard regularly
- Set up billing alerts for $30/month
- Use AWS Cost Explorer

---

## 🔍 Phase 6: Testing & Troubleshooting

### Step 1: Test Application
1. Visit your application URL
2. Test login functionality
3. Add a test lead
4. Check followups page

### Step 2: Monitor Logs
```bash
eb logs
```

### Step 3: Check Database Connection
1. SSH into instance: `eb ssh`
2. Test database connection:
```bash
python -c "
import psycopg2
conn = psycopg2.connect(
    host='gaadimech-crm-db.xxxxxx.ap-south-1.rds.amazonaws.com',
    database='crmportal',
    user='postgres',
    password='GaadiMech2024!'
)
print('Database connection successful!')
conn.close()
"
```

---

## 🛡️ Phase 7: Security Hardening

### Step 1: Update RDS Security Group
1. Go to **EC2 → Security Groups**
2. Find your EB security group (starts with `awseb-`)
3. Copy the security group ID
4. Update RDS security group:
   - Remove `0.0.0.0/0` rule
   - Add rule with EB security group as source

### Step 2: Enable HTTPS (Optional)
1. Get SSL certificate from AWS Certificate Manager
2. Configure Load Balancer to use HTTPS
3. Redirect HTTP to HTTPS

---

## 📋 Expected Monthly Costs

```
💰 Cost Breakdown (ap-south-1 region):

RDS db.t3.micro:
- Instance: ~$12/month
- Storage (20GB): ~$2/month

EC2 t3.micro (Elastic Beanstalk):
- Instance: ~$8/month (if not free tier)
- Load Balancer: ~$8/month

Data Transfer: ~$1-3/month

Total: ~$25-35/month
```

---

## 🚨 Troubleshooting Common Issues

### Issue 1: Database Connection Failed
**Solution**: Check security groups and RDS endpoint

### Issue 2: Application Won't Start
**Solution**: Check environment variables and logs with `eb logs`

### Issue 3: 502 Bad Gateway
**Solution**: Check application.py is the correct WSGI entry point

### Issue 4: High Costs
**Solution**: Use t3.micro instances and optimize RDS settings

---

## ✅ Success Checklist

- [ ] RDS PostgreSQL database created with db.t3.micro
- [ ] Security groups configured properly  
- [ ] Elastic Beanstalk environment created with t3.micro
- [ ] Environment variables set correctly
- [ ] Application deployed successfully
- [ ] Database initialized and working
- [ ] Application accessible via web browser
- [ ] Login functionality working
- [ ] Cost monitoring set up

---

## 🆘 Need Help?

If you encounter issues:
1. Check AWS CloudWatch logs
2. Use `eb logs` for application logs
3. Verify environment variables with `eb printenv`
4. Test database connectivity
5. Check security group rules

Your GaadiMech CRM should now be successfully deployed on AWS! 🎉 