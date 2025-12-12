# Backend - GaadiMech CRM

Flask backend API server for the GaadiMech CRM application.

## Setup

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure environment variables:**
   Create a `.env` file in this directory with:
   ```
   RDS_HOST=crm-portal-db.cnewyw0y0leb.ap-south-1.rds.amazonaws.com
   RDS_DB=crmportal
   RDS_USER=crmadmin
   RDS_PASSWORD=GaadiMech2024!
   RDS_PORT=5432
   SECRET_KEY=GaadiMech-Super-Secret-Key-Change-This-2024
   FLASK_ENV=development
   PORT=5000
   ```

3. **Run database migrations:**
   ```bash
   flask db upgrade
   ```

## Running Locally

```bash
python run_local.py
```

The server will start on `http://localhost:5000`

## API Endpoints

- `POST /login` - User login
- `GET /api/user/current` - Get current user info
- `GET /api/leads` - Get leads list
- `POST /api/leads` - Create new lead
- And more...

## CORS Configuration

The backend is configured to accept requests from:
- `http://localhost:3000` (Next.js dev server)
- `http://127.0.0.1:3000`

Make sure the frontend is running on port 3000 when testing locally.

