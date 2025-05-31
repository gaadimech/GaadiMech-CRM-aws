# Supabase to RDS Migration Guide

This guide walks you through the complete migration of your Supabase database to AWS RDS.

## 🎯 What This Migration Does

- **Safely exports** your entire Supabase database (schema + data)
- **Preserves all data integrity** - no data loss
- **Read-only operations** on Supabase - your source database remains untouched
- **Complete schema migration** including tables, indexes, constraints
- **Verification process** to ensure migration success

## 📋 Prerequisites

1. **PostgreSQL Tools**: Ensure `pg_dump` and `psql` are installed
   ```bash
   # macOS (using Homebrew)
   brew install postgresql
   
   # Ubuntu/Debian
   sudo apt-get install postgresql-client
   
   # CentOS/RHEL
   sudo yum install postgresql
   ```

2. **Python Dependencies**: Install required packages
   ```bash
   pip install psycopg2-binary
   ```

3. **Network Access**: Ensure your machine can connect to both:
   - Supabase database (source)
   - RDS database (target)

4. **RDS Database**: Your target RDS instance should be:
   - Running and accessible
   - PostgreSQL compatible
   - Empty or ready to be overwritten

## 🔧 Configuration

### 1. Verify Configuration

The migration uses the configuration in `migration_config.py`. Review and update if needed:

```bash
python migration_config.py
```

### 2. Update RDS Settings (if different)

Edit `migration_config.py` if your RDS settings are different:

```python
# Update these values in migration_config.py
RDS_HOST = "your-rds-endpoint.region.rds.amazonaws.com"
RDS_DB = "your-database-name"
RDS_USER = "your-username"
RDS_PASSWORD = "your-password"
RDS_PORT = "5432"
```

## 🚀 Migration Process

### Step 1: Test Connections (Dry Run)

First, test that everything is configured correctly:

```bash
python run_migration.py --dry-run
```

This will:
- Test connections to both databases
- Show database information
- Verify configuration
- **NOT** perform any migration

### Step 2: Run the Actual Migration

Once the dry run succeeds, run the actual migration:

```bash
python run_migration.py
```

## 📊 What Happens During Migration

1. **Connection Testing**: Verifies access to both databases
2. **Source Analysis**: Examines the Supabase database structure
3. **Backup Creation**: Creates a complete dump of Supabase data
4. **RDS Preparation**: Prepares the backup for RDS compatibility
5. **Data Restoration**: Imports everything into RDS
6. **Verification**: Compares source and target to ensure success

## 📁 Migration Files

The migration creates several files:

- `migration_YYYYMMDD_HHMMSS.log` - Detailed migration log
- Temporary backup files (automatically cleaned up)

## ✅ Verification

The migration automatically verifies:
- All tables are created
- Record counts match between source and target
- Data integrity is maintained

## 🔍 Troubleshooting

### Common Issues

1. **Connection Timeout**
   ```
   Solution: Check network connectivity and firewall settings
   ```

2. **Authentication Failed**
   ```
   Solution: Verify database credentials in migration_config.py
   ```

3. **pg_dump/psql Not Found**
   ```
   Solution: Install PostgreSQL client tools (see Prerequisites)
   ```

4. **Permission Denied**
   ```
   Solution: Ensure your RDS user has CREATE/DROP permissions
   ```

### Manual Verification

After migration, you can manually verify by connecting to both databases:

```bash
# Connect to Supabase
psql "postgresql://postgres.qcvfmiqzkfhinxlhknnd:gaadimech123@aws-0-ap-south-1.pooler.supabase.com:6543/postgres"

# Connect to RDS
psql "postgresql://postgres:GaadiMech2024!@gaadimech-crm-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com:5432/crmportal"

# Compare table counts
\dt
```

## 🔄 Post-Migration Steps

1. **Update Application Configuration**
   - Update your application's database URL to point to RDS
   - Test your application with the new database

2. **Performance Optimization**
   - Consider running `ANALYZE` on large tables
   - Review and optimize indexes if needed

3. **Backup Strategy**
   - Set up automated backups for your RDS instance
   - Configure retention policies

## 🛡️ Safety Features

- **Read-only source operations**: Never modifies Supabase
- **Verification checks**: Ensures data integrity
- **Detailed logging**: Complete audit trail
- **Cleanup**: Temporary files are automatically removed

## 📞 Support

If you encounter issues:

1. Check the migration log file for detailed error messages
2. Verify network connectivity to both databases
3. Ensure all prerequisites are met
4. Review the troubleshooting section above

## ⚠️ Important Notes

- **Backup Recommendation**: Although this migration is safe, consider backing up your RDS database before running
- **Downtime**: Plan for application downtime while switching database connections
- **Testing**: Test your application thoroughly with the new RDS database
- **Supabase**: Your Supabase database remains unchanged and can still be used if needed

## 🎯 Next Steps After Migration

1. Update your Flask application's database configuration
2. Test all application functionality
3. Monitor RDS performance and adjust instance size if needed
4. Set up CloudWatch monitoring for your RDS instance
5. Configure automated backups and maintenance windows 