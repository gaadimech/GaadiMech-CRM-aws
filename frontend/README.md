# GaadiMech CRM - TypeScript Frontend

A modern, mobile-first CRM frontend built with Next.js, TypeScript, and Tailwind CSS.

## 🎯 Pages Created

### 1. **Login Page** (`/login`)
- Clean authentication form
- Session-based auth with Flask backend
- Redirects to dashboard on success

### 2. **Dashboard** (`/dashboard`)
- Key metrics cards (Today's Followups, Initial Assignment, Completion Rate, New Leads)
- Today's pending followups list with quick actions
- Team performance table with completion rates
- Date filter for viewing historical data
- Mobile-responsive design

### 3. **Add Lead** (`/add-lead`)
- Complete form for adding new leads
- All required fields (customer name, mobile, car registration, followup date, status, remarks)
- Validation and error handling
- Mobile-optimized input fields

### 4. **View Followups** (`/followups`)
- Advanced search and filter system
- Search by name, mobile, car registration
- Filter by date (followup, created, modified)
- Filter by status and team member
- Paginated table view
- Quick action buttons (Call, WhatsApp, Status, Reschedule)

### 5. **Admin Leads** (`/admin/leads`)
- AI Text Parser for extracting customer info from messages
- Add new lead form with team assignment
- Recent leads list with filters
- Admin-only access (conditional navigation)

### 6. **Home** (`/`)
- Redirects to dashboard

## 🧩 Components

### Shared Components
- **Nav** - Main navigation bar with active state highlighting
- **StatusBadge** - Color-coded status indicators
- **ActionButtons** - Reusable call/WhatsApp/status/reschedule buttons

## 🔌 API Integration

The frontend expects these Flask endpoints:

### Existing Endpoints (Already in Flask)
- `POST /login` - Authentication
- `POST /add_lead` - Add new lead
- `GET /followups` - View all followups (needs JSON response)
- `POST /admin_leads` - Admin lead management

### New Endpoints Needed (To be added to Flask)
- `GET /api/followups/today` - Get today's followups queue
- `GET /api/dashboard/metrics` - Dashboard metrics
- `GET /api/dashboard/team-performance` - Team performance data
- `GET /api/followups` - Search/filter followups (JSON)
- `POST /api/followups/bulk-status` - Bulk status update
- `POST /api/followups/bulk-reschedule` - Bulk reschedule
- `POST /api/whatsapp/send` - Send WhatsApp message
- `GET /api/admin/unassigned-leads` - Get unassigned leads
- `GET /api/admin/team-members` - Get team members list
- `GET /api/user/current` - Get current user info (for admin check)

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd frontend
npm install
```

### 2. Configure Environment
Create `.env.local` file:
```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:5000
```

### 3. Run Development Server
```bash
npm run dev
```

The frontend will run on `http://localhost:3000`

### 4. Run Flask Backend
In the root directory:
```bash
python application.py
```

The backend should run on `http://localhost:5000`

## 📱 Mobile-First Design

All pages are optimized for mobile devices:
- Touch-friendly buttons (minimum 44x44px)
- Responsive grid layouts
- Mobile-optimized forms
- Swipe-friendly cards
- Minimal clutter

## 🎨 Design System

- **Colors**: Zinc-based palette (zinc-50 to zinc-900)
- **Typography**: System fonts with proper hierarchy
- **Spacing**: Consistent 4px grid (Tailwind defaults)
- **Components**: Rounded corners, subtle shadows, clean borders

## 🔄 Next Steps

1. **Backend Integration**: Add the missing Flask API endpoints
2. **WhatsApp Integration**: Implement WhatsApp Cloud API
3. **Real-time Updates**: Add WebSocket support for live updates
4. **Offline Support**: Add service worker for offline functionality
5. **Testing**: Add unit and integration tests

## 📝 Notes

- All API calls use `credentials: "include"` for session cookies
- The frontend assumes same-origin with Flask backend (no CORS needed in dev)
- For production, configure CORS in Flask or use a reverse proxy
