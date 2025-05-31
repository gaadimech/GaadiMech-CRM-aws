# AWS Deployment Guide for CRM Portal

## Architecture Overview

**Recommended Setup:**
- **Compute**: AWS Elastic Beanstalk (t3.small instances)
- **Database**: Amazon RDS PostgreSQL (db.t3.micro)
- **Cost**: ~$35-50/month for low-medium traffic

## Step-by-Step Deployment

### Phase 1: Set Up AWS RDS Database

#### 1.1 Create RDS PostgreSQL Instance
```bash
# Via AWS CLI (alternative to console)
aws rds create-db-instance \
    --db-name crmportal \
    --db-instance-identifier crm-portal-db \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --master-username postgres \
    --master-user-password YOUR_SECURE_PASSWORD \
    --allocated-storage 20 \
    --vpc-security-group-ids sg-xxxxxxxx \
    --publicly-accessible \
    --backup-retention-period 7
```

#### 1.2 Manual Steps in AWS Console:
1. Go to **AWS RDS Console**
2. Click **Create Database**
3. Choose **PostgreSQL**
4. Select **Free Tier** or **Production** based on needs
5. Configure:
   - **DB Instance Class**: `db.t3.micro` (Free tier) or `db.t3.small`
   - **Storage**: 20GB (can auto-scale)
   - **DB Name**: `crmportal`
   - **Master Username**: `postgres`
   - **Master Password**: Create a secure password
6. **VPC Security Group**: Allow inbound PostgreSQL (5432) from Elastic Beanstalk
7. **Backup**: 7-day retention
8. Click **Create Database**

#### 1.3 Configure Security Group
1. Go to **EC2 Console > Security Groups**
2. Find your RDS security group
3. Add inbound rule:
   - **Type**: PostgreSQL (5432)
   - **Source**: Elastic Beanstalk security group or 0.0.0.0/0 (less secure)

### Phase 2: Prepare Application for AWS

#### 2.1 Update requirements.txt
Add these AWS-specific packages:
```txt
# Existing packages...
Flask==2.3.3
Flask-SQLAlchemy==3.0.5
Flask-Login==0.6.3
Flask-Migrate==4.0.5
Flask-Limiter==3.5.0
psycopg2-binary==2.9.9
SQLAlchemy==2.0.25
python-dotenv==1.0.0
Werkzeug==2.3.7
pytz==2023.3.post1
APScheduler==3.10.4
gunicorn==21.2.0
requests==2.31.0
redis==5.0.1
Flask-Caching==2.1.0

# AWS specific
awsebcli==3.20.10
boto3==1.34.0
```

#### 2.2 Create Environment Variables File
Create `.env.example`:
```bash
SECRET_KEY=your-super-secret-key-change-this
DATABASE_URL=postgresql://postgres:password@your-rds-endpoint.amazonaws.com:5432/crmportal
RDS_HOST=your-rds-endpoint.amazonaws.com
RDS_DB=crmportal
RDS_USER=postgres
RDS_PASSWORD=your-secure-password
RDS_PORT=5432
FLASK_ENV=production
```

### Phase 3: Deploy with Elastic Beanstalk

#### 3.1 Install EB CLI
```bash
pip install awsebcli
```

#### 3.2 Initialize Elastic Beanstalk
```bash
# Navigate to your project directory
cd /path/to/your/crm-portal

# Initialize EB application
eb init

# Follow prompts:
# - Region: ap-south-1 (Mumbai) or your preferred region
# - Application name: crm-portal
# - Platform: Python 3.11
# - CodeCommit: No
# - SSH: Yes (recommended)
```

#### 3.3 Create and Deploy Environment
```bash
# Create environment (this will take 5-10 minutes)
eb create crm-production

# Set environment variables
eb setenv SECRET_KEY="your-super-secret-key"
eb setenv DATABASE_URL="postgresql://postgres:password@your-rds-endpoint.amazonaws.com:5432/crmportal"
eb setenv FLASK_ENV="production"

# Deploy your application
eb deploy
```

#### 3.4 Configure Environment Variables in Console
1. Go to **Elastic Beanstalk Console**
2. Select your environment: `crm-production`
3. Go to **Configuration > Software**
4. Add environment variables:
   ```
   SECRET_KEY = your-super-secret-key-change-this
   DATABASE_URL = postgresql://postgres:password@your-rds-endpoint:5432/crmportal
   RDS_HOST = your-rds-endpoint.amazonaws.com
   RDS_DB = crmportal
   RDS_USER = postgres
   RDS_PASSWORD = your-secure-password
   RDS_PORT = 5432
   FLASK_ENV = production
   ```

### Phase 4: Database Migration

#### 4.1 Initialize Database Schema
```bash
# SSH into your EB instance
eb ssh

# Run database migrations
cd /var/app/current
source /var/app/venv/*/bin/activate
python application.py

# Or manually run Flask commands
export FLASK_APP=application.py
flask db upgrade
```

#### 4.2 Data Migration (if needed)

If you have existing data, you can migrate it using standard PostgreSQL tools:

```bash
# Export from old database
pg_dump "your_old_database_url" > backup.sql

# Import to AWS RDS
psql "postgresql://postgres:GaadiMech2024!@gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal" < backup.sql
```

### Phase 5: Domain and SSL Setup

#### 5.1 Custom Domain (Optional)
1. Go to **Route 53** or your DNS provider
2. Create CNAME record pointing to your EB environment URL
3. In **Elastic Beanstalk > Configuration > Load Balancer**
4. Add listener for HTTPS with SSL certificate

#### 5.2 SSL Certificate
1. Go to **AWS Certificate Manager**
2. Request public certificate for your domain
3. Add to Load Balancer in EB configuration

### Phase 6: Monitoring and Optimization

#### 6.1 CloudWatch Monitoring
```bash
# Enable enhanced health reporting
eb config
```

#### 6.2 Auto Scaling Configuration
1. **Elastic Beanstalk > Configuration > Capacity**
2. Set:
   - **Min instances**: 1
   - **Max instances**: 2-3
   - **Scaling triggers**: CPU > 70%

## Cost Optimization Tips

### 1. Right-Size Your Instances
- **Start Small**: `t3.micro` or `t3.small`
- **Monitor Usage**: Use CloudWatch metrics
- **Scale Gradually**: Only upgrade when needed

### 2. Database Optimization
- **RDS**: Use `db.t3.micro` for development
- **Storage**: Start with 20GB, enable auto-scaling
- **Backups**: Use automated backups, not manual snapshots

### 3. Use AWS Free Tier
- **New AWS accounts**: 12 months free tier
- **RDS**: 750 hours/month free on db.t3.micro
- **EB**: No additional charges (only for underlying resources)

## Expected Monthly Costs

### Low Traffic (< 1000 users/month)
- **EC2 t3.micro**: $8-10/month
- **RDS db.t3.micro**: $15-20/month
- **Data Transfer**: $2-5/month
- **Total**: ~$25-35/month

### Medium Traffic (1000-5000 users/month)
- **EC2 t3.small**: $15-20/month
- **RDS db.t3.small**: $25-30/month
- **Load Balancer**: $18/month
- **Data Transfer**: $5-10/month
- **Total**: ~$63-88/month

## Deployment Commands Summary

```bash
# One-time setup
pip install awsebcli
eb init
eb create crm-production

# Regular deployments
eb deploy

# Environment management
eb status
eb health
eb logs
eb open

# Configuration
eb setenv KEY=VALUE
eb config
```

## Troubleshooting

### Common Issues:

1. **Database Connection Errors**
   - Check RDS security group
   - Verify DATABASE_URL format
   - Ensure RDS is publicly accessible

2. **Application Won't Start**
   - Check logs: `eb logs`
   - Verify application.py exists
   - Check requirements.txt

3. **Migration Failures**
   - SSH into instance: `eb ssh`
   - Run migrations manually
   - Check database permissions

### Health Check Commands:
```bash
# Check application status
eb status

# View recent logs
eb logs

# Open application in browser
eb open

# Monitor health
eb health --refresh
```

## Security Best Practices

1. **Environment Variables**: Never commit secrets to code
2. **RDS Security**: Use VPC and security groups
3. **SSL**: Always use HTTPS in production
4. **Backups**: Enable automated RDS backups
5. **Updates**: Regularly update dependencies

## Migration Checklist

- [ ] Create RDS PostgreSQL instance
- [ ] Configure security groups
- [ ] Update application.py for AWS
- [ ] Set up EB CLI
- [ ] Initialize EB application
- [ ] Create production environment
- [ ] Set environment variables
- [ ] Deploy application
- [ ] Run database migrations
- [ ] Test all functionality
- [ ] Set up monitoring
- [ ] Configure auto-scaling
- [ ] Set up custom domain (optional)
- [ ] Enable SSL certificate
- [ ] Update DNS records
- [ ] Perform load testing

This guide provides a complete path from your current Render deployment to a production-ready AWS setup optimized for cost and performance. 