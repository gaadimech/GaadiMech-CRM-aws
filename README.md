# GaadiMech CRM Portal

A comprehensive Customer Relationship Management (CRM) system built with Flask for tracking telecaller performance and lead management.

## Features

### 🎯 Dashboard Analytics
- **Today's Followups**: View and manage all scheduled followups for the current date
- **Performance Metrics**: Track daily, weekly, and monthly lead creation statistics
- **User Performance Ranking**: Leaderboard showing team member performance
- **Lead Status Breakdown**: Visual charts showing status distribution
- **Advanced Analytics**: Peak hours analysis, conversion rates, and efficiency metrics

### 📊 Key Dashboard Components

#### 1. Today's Followups Section
- Default view shows today's followups for all users
- Filter by specific telecaller using dropdown
- Display customer name, mobile, followup time, status, and remarks
- Click-to-call functionality for mobile numbers
- Quick action buttons: Confirm, Reschedule, Mark as No Answer
- WhatsApp integration for direct messaging

#### 2. Performance Metrics Cards
- Today's followups count
- Leads created today
- Monthly leads total
- Follow-up efficiency percentage

#### 3. Interactive Charts
- **Status Pie Chart**: Visual breakdown of lead statuses
- **7-Day Trend**: Line chart showing lead creation over the past week
- **Hourly Analysis**: Bar chart showing peak performance hours

#### 4. Team Performance
- Ranked list of team members by leads created
- Shows followups due, confirmed leads, and completed leads
- Real-time performance tracking

#### 5. Advanced Analytics
- Peak performance hours identification
- Status conversion rates with progress bars
- Quick stats overview
- Export functionality for reports

### 🔧 Technical Features
- **Real-time Updates**: Dashboard auto-refreshes every 5 minutes
- **Mobile Responsive**: Works on desktop, tablet, and mobile devices
- **Role-based Access**: Different views for admins vs regular users
- **Date Range Filtering**: View data for any specific date
- **Export Functionality**: Generate CSV reports
- **Interactive Elements**: Hover effects, tooltips, and smooth animations

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd crm-portal
```

2. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Set up environment variables:
```bash
# Create a .env file with:
SECRET_KEY=your_secret_key_here
DATABASE_URL=your_supabase_database_url
```

5. Initialize the database:
```bash
flask db upgrade
```

6. Run the application:
```bash
python app.py
```

## Database Schema

### User Table
- `id`: Primary key
- `username`: Unique username
- `password_hash`: Hashed password
- `name`: Display name
- `is_admin`: Boolean for admin privileges

### Lead Table
- `id`: Primary key
- `customer_name`: Customer's name
- `mobile`: Phone number (10-12 digits)
- `car_registration`: Vehicle registration (optional)
- `followup_date`: Scheduled followup datetime
- `remarks`: Notes and comments
- `status`: Lead status (Did Not Pick Up, Needs Followup, Confirmed, Open, Completed, Feedback)
- `created_at`: Creation timestamp
- `modified_at`: Last modification timestamp
- `creator_id`: Foreign key to User table

## Usage

### Dashboard Navigation
1. **Login** with your credentials
2. **Dashboard**: Main analytics view (new feature)
3. **Add Lead**: Create new leads
4. **View Followups**: Search and manage existing leads

### Dashboard Features

#### Viewing Today's Followups
- Dashboard loads with today's followups by default
- Use the date picker to view followups for other dates
- Admin users can filter by team member using the dropdown

#### Quick Actions
- **Copy Phone Number**: Click on any phone number to copy to clipboard
- **WhatsApp Integration**: Click WhatsApp button to open chat
- **Status Updates**: Use quick action buttons to update lead status
- **Reschedule Followups**: Click reschedule to set new followup date

#### Performance Tracking
- View team rankings and individual performance
- Track conversion rates and efficiency metrics
- Analyze peak performance hours
- Export data for external reporting

#### Filtering Options
- **Date Filter**: Select any date to view historical data
- **User Filter**: (Admin only) Filter by specific team member
- **Real-time Refresh**: Click refresh button or wait for auto-refresh

### User Roles

#### Admin Users
- View all team members' data
- Filter dashboard by specific users
- Access to modified date tracking
- Full lead management capabilities

#### Regular Users
- View only their own leads and followups
- Personal performance metrics
- Standard lead management features

## API Endpoints

### Dashboard APIs
- `GET /dashboard`: Main dashboard view
- `POST /api/dashboard/status-update`: Update lead status
- `POST /api/dashboard/quick-followup`: Schedule new followup

### Existing APIs
- `GET /`: Add lead page
- `POST /add_lead`: Create new lead
- `GET /followups`: View and search leads
- `GET|POST /edit_lead/<id>`: Edit lead details
- `POST /delete_lead/<id>`: Delete lead

## Browser Compatibility
- Chrome 70+
- Firefox 65+
- Safari 12+
- Edge 79+

## Mobile Support
- Responsive design works on all screen sizes
- Touch-friendly interface
- Optimized charts for mobile viewing

## Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Security Features
- Session management with Flask-Login
- Rate limiting on sensitive endpoints
- CSRF protection
- Secure password hashing
- Role-based access control

## Performance Optimizations
- Efficient database queries with proper indexing
- Lazy loading for large datasets
- Client-side caching
- Optimized chart rendering
- Auto-refresh only when page is visible

## Troubleshooting

### Common Issues
1. **Dashboard not loading**: Check database connection and ensure migrations are applied
2. **Charts not displaying**: Verify Chart.js is loading correctly
3. **WhatsApp integration not working**: Check user agent detection
4. **Performance issues**: Review database indexes and query optimization

### Support
For issues or questions, please check the application logs and ensure all dependencies are properly installed. 