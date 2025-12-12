# GaadiMech CRM

Customer Relationship Management system for GaadiMech.

## Project Structure

This project is split into two independent applications:

```
GaadiMech-CRM-aws/
├── backend/          # Flask/Python backend API
├── frontend/         # Next.js frontend application
└── README.md         # This file
```

## Quick Start

### Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Configure environment variables (create `.env` file):
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

4. Run database migrations:
   ```bash
   flask db upgrade
   ```

5. Start the backend server:
   ```bash
   python run_local.py
   ```

   Backend will run on `http://localhost:5000`

### Frontend Setup

1. Navigate to frontend directory:
   ```bash
   cd frontend
   ```

2. Install Node.js dependencies:
   ```bash
   npm install
   ```

3. Configure environment variables (create `.env.local` file):
   ```
   NEXT_PUBLIC_API_BASE_URL=http://localhost:5000
   ```

4. Start the frontend development server:
   ```bash
   npm run dev
   ```

   Frontend will run on `http://localhost:3000`

## Testing

1. **Test Backend Independently:**
   - Start only the backend server
   - Test API endpoints using curl or Postman:
     ```bash
     curl http://localhost:5000/api/user/current
     ```

2. **Test Frontend Independently:**
   - Start only the frontend server
   - Navigate to `http://localhost:3000`
   - Frontend should load (but API calls will fail if backend is not running)

3. **Test Both Together:**
   - Start both backend and frontend servers
   - Navigate to `http://localhost:3000`
   - Login and verify all features work correctly

## Development Workflow

1. Start backend server in one terminal:
   ```bash
   cd backend && python run_local.py
   ```

2. Start frontend server in another terminal:
   ```bash
   cd frontend && npm run dev
   ```

3. Access the application at `http://localhost:3000`

## Deployment

For deployment, each application can be deployed separately:
- Backend: Deploy to AWS Elastic Beanstalk, Heroku, or similar
- Frontend: Deploy to Vercel, Netlify, or serve as static files

See individual README files in `backend/` and `frontend/` directories for more details.
