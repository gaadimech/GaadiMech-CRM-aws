# Admin Role Fix Guide

## Problem
Admin features (Password Manager, Admin Leads, Leads Manipulation) are not visible in the sidebar even when logged in as admin.

## Root Cause
The admin user's `is_admin` field in the database might be `False` or `NULL`, preventing the frontend from showing admin navigation items.

## Solution

### Option 1: Run the Fix Script (Recommended)

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies (if not already done):**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the fix script:**
   ```bash
   python3 fix_admin_role.py
   ```

   This script will:
   - Check if admin user exists
   - Verify the `is_admin` field
   - Fix it if it's `False` or `NULL`
   - Create admin user if it doesn't exist

### Option 2: Fix via Database Directly

If you have direct database access:

```sql
-- Check current admin user status
SELECT id, username, name, is_admin FROM "user" WHERE username = 'admin';

-- Fix admin role
UPDATE "user" SET is_admin = TRUE WHERE username = 'admin';

-- Verify
SELECT id, username, name, is_admin FROM "user" WHERE username = 'admin';
```

### Option 3: Automatic Fix on Next Backend Start

The `init_database()` function has been updated to automatically fix admin users on startup. Simply restart your backend server:

```bash
cd backend
python3 run_local.py
```

## Verification

### 1. Check Backend API Response

Test the API endpoint directly:

```bash
# Login first (get session cookie)
curl -X POST http://localhost:5000/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin@796!"}' \
  -c cookies.txt

# Check current user
curl http://localhost:5000/api/user/current \
  -b cookies.txt \
  -H "Content-Type: application/json"
```

**Expected response:**
```json
{
  "id": 1,
  "username": "admin",
  "name": "Administrator",
  "is_admin": true
}
```

**If `is_admin` is `false` or missing, the fix didn't work.**

### 2. Check Browser Console

1. Open your application in browser (`http://localhost:3000`)
2. Open Developer Tools (F12)
3. Go to Console tab
4. Look for logs starting with `[Sidebar]`:
   - `[Sidebar] User data from API:` - Should show `is_admin: true`
   - `[Sidebar] is_admin value:` - Should show `true`
   - `[Sidebar] isAdmin state set to:` - Should show `true`

### 3. Check Sidebar

After fixing and refreshing:
- You should see an "Admin" section in the sidebar
- It should contain:
  - **Admin Leads**
  - **Leads Manipulation**
  - **Passwords** (Password Manager)

## Troubleshooting

### Issue: Script fails with "ModuleNotFoundError"

**Solution:** Install backend dependencies:
```bash
cd backend
pip install -r requirements.txt
```

### Issue: Script fails with database connection error

**Solution:** 
1. Check your `.env` file has correct database credentials
2. Verify database is accessible
3. Check RDS security groups allow your IP

### Issue: API returns `is_admin: false` after fix

**Solution:**
1. Verify the database update worked:
   ```sql
   SELECT username, is_admin FROM "user" WHERE username = 'admin';
   ```
2. Clear browser cookies and login again
3. Check backend logs for any errors

### Issue: Frontend still doesn't show admin items

**Solution:**
1. Check browser console for `[Sidebar]` logs
2. Verify API response has `is_admin: true`
3. Hard refresh browser (Cmd+Shift+R or Ctrl+Shift+R)
4. Clear browser cache
5. Check if `isAdmin` state is being set correctly in React DevTools

## Prevention

The `init_database()` function now automatically ensures admin users have `is_admin=True` on every backend startup. This prevents the issue from happening again.

## Files Modified

1. **backend/application.py** - Updated `init_database()` to fix existing admin users
2. **backend/fix_admin_role.py** - New script to manually fix admin role
3. **frontend/src/components/Sidebar.tsx** - Added debug logging to help diagnose issues

## Next Steps

After fixing:
1. ✅ Run the fix script
2. ✅ Verify API returns `is_admin: true`
3. ✅ Refresh frontend and check browser console
4. ✅ Verify admin navigation items appear in sidebar
5. ✅ Test admin features (Password Manager, Admin Leads, etc.)
