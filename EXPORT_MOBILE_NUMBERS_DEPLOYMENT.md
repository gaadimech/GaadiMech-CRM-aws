# GaadiMech CRM - Export Mobile Numbers Deployment Guide

## Package Information
- **File**: `gaadimech-crm-export-mobile-numbers-20250703_213111.zip`
- **Created**: July 3, 2025
- **Size**: ~44KB

## New Features Added

### 📱 Export Mobile Numbers Functionality
The Export button on the dashboard now generates and downloads a CSV file containing mobile numbers instead of overview metrics.

#### What the Export Button Does Now:
1. **All Team Members Selected**: Exports all mobile numbers for the selected followup date
2. **Specific Team Member Selected**: Exports only mobile numbers for that team member's followups on the selected date
3. **Non-admin Users**: Can only export their own followup mobile numbers

#### CSV Format:
```csv
Mobile Number,Customer Name,Car Registration,Status,Created By
9401605487,gaadimech,ABC123,Needs Followup,Hemlata
6351170688,gaadimech,,Did Not Pick Up,Sneha
```

## Files Included in Deployment Package

### Core Application Files:
- `application.py` - Main Flask application with new `/api/export-mobile-numbers` endpoint
- `dashboard_optimized.py` - Dashboard optimization module
- `requirements.txt` - Python dependencies (Flask, SQLAlchemy, etc.)
- `runtime.txt` - Python 3.11.6 runtime specification

### Templates (Updated):
- `templates/dashboard.html` - Updated with new export functionality
- `templates/index.html`, `templates/login.html`, `templates/edit_lead.html`
- `templates/followups.html`, `templates/error.html`

### AWS Configuration:
- `Procfile` - Gunicorn web server configuration

## Deployment Instructions

### 1. AWS Elastic Beanstalk Deployment
```bash
# Upload the zip file to your Elastic Beanstalk environment
# The package is ready for direct deployment
```

### 2. Environment Variables Required
Make sure these environment variables are set in your AWS EB environment:
```
DATABASE_URL=your_postgresql_connection_string
SECRET_KEY=your_secret_key
RDS_HOST=your_rds_endpoint
RDS_DB=crmportal
RDS_USER=postgres
RDS_PASSWORD=your_password
```

### 3. Post-Deployment Verification
1. Access your dashboard at: `https://your-domain.com/dashboard`
2. Select a date and team member (or "All Team Members")
3. Click the "Export" button
4. Verify that a CSV file downloads with mobile numbers

## Backend Changes Made

### New API Endpoint
- **Route**: `/api/export-mobile-numbers`
- **Method**: GET
- **Parameters**: 
  - `date` (YYYY-MM-DD format)
  - `user_id` (optional, for team member filtering)

### Frontend Changes
- Modified `exportData()` function in dashboard templates
- Changed from client-side CSV generation to server-side download
- Updated success message to "Mobile numbers exported successfully"

## Security Features
- Admin users can export for any team member
- Regular users can only export their own followups
- Proper authentication required for all export operations

## Database Requirements
- No database schema changes required
- Uses existing `Lead` and `User` tables
- Filters based on `followup_date` and `creator_id`

## Testing Checklist
- [ ] Admin can export all mobile numbers for selected date
- [ ] Admin can export specific team member's mobile numbers
- [ ] Regular user can only export their own mobile numbers
- [ ] CSV file downloads correctly with proper formatting
- [ ] File naming follows pattern: `mobile_numbers_YYYY-MM-DD.csv`

## Support
If you encounter any issues with the deployment, check:
1. Environment variables are correctly set
2. Database connection is working
3. All template files are properly deployed
4. Browser console for any JavaScript errors 