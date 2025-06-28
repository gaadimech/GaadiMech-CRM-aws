# Quick Deployment Guide - 502 Error Fix

## Files Ready for Deployment
✅ **gaadimech-crm-502-fix.zip** - Contains all fixed files

## What Was Fixed
1. **Removed APScheduler** - Was causing multi-instance conflicts on AWS
2. **Removed zoneinfo import** - Not available in AWS Python runtime  
3. **Simplified database connection** - Removed complex psycopg detection
4. **Fixed session cookies** - Made compatible with AWS ALB
5. **Removed HTTPS redirect** - Was causing redirect loops
6. **Changed port to 5000** - Better AWS compatibility

## Deployment Steps

### Option 1: AWS Elastic Beanstalk Console
1. Go to AWS Elastic Beanstalk console
2. Select your environment
3. Click "Upload and deploy"
4. Upload `gaadimech-crm-502-fix.zip`
5. Deploy

### Option 2: EB CLI
```bash
eb deploy --staged
```

## Post-Deployment Verification

1. **Check Health**: Visit `https://your-domain/health`
2. **Database Test**: Visit `https://your-domain/test_db`
3. **Login Test**: Try logging into the CRM
4. **Dashboard Test**: Check if dashboard loads without errors

## Important Notes

⚠️ **Daily Snapshots**: APScheduler is disabled. You can:
- Manually trigger via `/api/trigger-snapshot` (admin only)
- Set up AWS Lambda for automated daily snapshots
- Use external cron job

## If Issues Persist

1. Check AWS CloudWatch logs
2. Verify environment variables are set
3. Test database connectivity
4. Check security group settings

## Environment Variables Needed
```
DATABASE_URL=postgresql://...
SECRET_KEY=GaadiMech2024!
RDS_HOST=gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com
RDS_DB=crmportal
RDS_USER=postgres
RDS_PASSWORD=GaadiMech2024!
RDS_PORT=5432
```

The 502 errors should be resolved with these fixes! 🚀 