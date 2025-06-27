# 🚀 Clean Deployment Steps for GaadiMech CRM

## Prerequisites
1. Ensure you have AWS CLI and EB CLI installed
2. Your AWS credentials are configured
3. Your existing RDS database: `crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com`

## Step 1: Initialize New Elastic Beanstalk Application

```bash
cd deploy_clean
eb init
```

**Choose these options:**
- Region: `6` (ap-south-1 : Asia Pacific (Mumbai))
- Application name: `gaadimech-crm-clean`
- Platform: `Python 3.11` (or latest available)
- Platform branch: `Python 3.11 running on 64bit Amazon Linux 2023`
- CodeCommit: `N` (No)
- SSH keypair: `Y` (Yes - for debugging)

## Step 2: Create New Environment

```bash
eb create gaadimech-crm-prod-new --instance-types t3.micro
```

**Environment creation prompts:**
- Environment name: `gaadimech-crm-prod-new`
- DNS CNAME prefix: `gaadimech-crm-prod-new` (or choose unique name)
- Load balancer type: `Application Load Balancer`

⏱️ **Wait 10-15 minutes** for environment creation.

## Step 3: Set Environment Variables for Your Existing RDS

```bash
eb setenv SECRET_KEY="GaadiMech-Super-Secret-Key-Change-This-2024"
eb setenv DATABASE_URL="postgresql://postgres:GaadiMech2024!@crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal"
eb setenv RDS_HOST="crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com"
eb setenv RDS_DB="crmportal"
eb setenv RDS_USER="postgres"
eb setenv RDS_PASSWORD="GaadiMech2024!"
eb setenv RDS_PORT="5432"
eb setenv FLASK_ENV="production"
```

## Step 4: Deploy Application

```bash
eb deploy
```

⏱️ **Wait 5-10 minutes** for deployment.

## Step 5: Test Deployment

```bash
eb open
```

This will open your application in the browser.

## Step 6: Test Database Connection

Visit: `https://your-app-url.amazonaws.com/test_db`

You should see your database version and existing tables.

## Step 7: Clean Up Old Environments (After Testing)

Once the new deployment is working:

1. Go to AWS Console → Elastic Beanstalk
2. Select your old environments
3. Click "Terminate" to remove them and save costs

## Troubleshooting

### If deployment fails:
```bash
eb logs
```

### If database connection fails:
1. Check RDS security group allows connections from EB
2. Verify environment variables are set correctly:
   ```bash
   eb printenv
   ```

### To update environment variables:
```bash
eb setenv VARIABLE_NAME="new_value"
```

## Important Notes

1. **Your data is safe** - we're connecting to your existing RDS database
2. **Free tier usage** - t3.micro instances are free tier eligible
3. **Domain**: You'll get a new domain like `gaadimech-crm-prod-new.ap-south-1.elasticbeanstalk.com`
4. **SSL**: AWS provides SSL certificate automatically

## Next Steps After Successful Deployment

1. Test all functionality thoroughly
2. Update any DNS records if needed
3. Terminate old environments to avoid charges
4. Set up monitoring and backups if required 