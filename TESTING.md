# Testing Guide - Separated Frontend and Backend

This guide will help you test the separated frontend and backend applications.

## Prerequisites

1. **Python 3.9+** installed
2. **Node.js 18+** and npm installed
3. **PostgreSQL database** accessible (RDS or local)

## Step 1: Setup Backend

```bash
cd backend

# Install Python dependencies
pip install -r requirements.txt

# Verify setup
./test_backend.sh

# Start backend server
python3 run_local.py
```

The backend should start on `http://localhost:5000`

**Expected output:**
```
🚀 Starting GaadiMech CRM locally...
📍 Database: crm-portal-db
🌐 Server: http://localhost:5000
==================================================
 * Running on http://0.0.0.0:5000
```

**Test backend API:**
```bash
# In another terminal
curl http://localhost:5000/api/user/current
# Should return: {"error":"Not authenticated"}
```

## Step 2: Setup Frontend

```bash
# In a new terminal
cd frontend

# Install Node.js dependencies (if not already done)
npm install

# Verify setup
./test_frontend.sh

# Start frontend server
npm run dev
```

The frontend should start on `http://localhost:3000`

**Expected output:**
```
  ▲ Next.js 16.0.8
  - Local:        http://localhost:3000
  - Ready in 2.3s
```

**Test frontend:**
- Open browser to `http://localhost:3000`
- You should see the login page
- Frontend should be able to make API calls to backend

## Step 3: Test Both Together

1. **Backend running** on `http://localhost:5000`
2. **Frontend running** on `http://localhost:3000`

**Test flow:**
1. Open `http://localhost:3000` in browser
2. Open browser DevTools (F12) → Network tab
3. Try to login with credentials:
   - Username: `admin`
   - Password: `admin@796!`
4. Check Network tab - you should see API calls to `http://localhost:5000/api/login`
5. After successful login, you should be redirected to dashboard
6. Verify all features work (leads, followups, etc.)

## Troubleshooting

### Backend Issues

**Import errors:**
```bash
pip install -r requirements.txt
```

**Database connection errors:**
- Check `.env` file has correct database credentials
- Verify database is accessible from your network
- Check RDS security groups allow your IP

**Port already in use:**
```bash
# Find process using port 5000
lsof -i :5000
# Kill the process or change PORT in .env
```

### Frontend Issues

**Module not found:**
```bash
rm -rf node_modules package-lock.json
npm install
```

**API calls failing:**
- Verify backend is running on port 5000
- Check `.env.local` has `NEXT_PUBLIC_API_BASE_URL=http://localhost:5000`
- Check browser console for CORS errors
- Verify backend CORS allows `http://localhost:3000`

**Build errors:**
```bash
rm -rf .next out
npm run build
```

## Verification Checklist

- [ ] Backend starts without errors
- [ ] Backend API responds to `/api/user/current`
- [ ] Frontend starts without errors
- [ ] Frontend loads at `http://localhost:3000`
- [ ] Frontend can make API calls to backend
- [ ] Login works correctly
- [ ] Dashboard loads after login
- [ ] No CORS errors in browser console
- [ ] All features work as expected

## Next Steps

Once both are working locally:
1. Backend can be deployed independently (AWS EB, Heroku, etc.)
2. Frontend can be deployed independently (Vercel, Netlify, etc.)
3. Or both can be deployed together with proper configuration

