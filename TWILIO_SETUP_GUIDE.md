# 📞 Twilio Click-to-Call Setup Guide

## Overview

The Click-to-Call feature allows telecallers to initiate calls with a single click directly from the CRM. When clicked:
1. Twilio calls the telecaller first
2. When the telecaller answers, Twilio connects them to the customer
3. All calls are automatically logged in the CRM for tracking and analytics

## 🎯 Benefits

- **Save 20-30 seconds per call** - No manual dialing
- **Automatic call logging** - Every call tracked with duration and status
- **Professional caller ID** - Customers see your business number
- **Call recording** - (Optional) Record calls for quality and training
- **Better analytics** - Track call success rates, durations, and patterns

---

## 📋 Prerequisites

- Twilio account (Sign up at https://www.twilio.com)
- A Twilio phone number with voice capabilities
- Credit card for Twilio billing (starts at ~$15/month for basic usage)

---

## 🚀 Setup Instructions

### Step 1: Create Twilio Account

1. Go to https://www.twilio.com/try-twilio
2. Sign up for a free trial account
3. Verify your email and phone number
4. You'll receive $15.50 in trial credit

### Step 2: Get Twilio Credentials

1. Go to your Twilio Console: https://console.twilio.com
2. From the dashboard, copy:
   - **Account SID** (starts with "AC...")
   - **Auth Token** (click to reveal)

### Step 3: Buy a Phone Number

1. In Twilio Console, go to **Phone Numbers** → **Buy a Number**
2. Select your country (India: +91)
3. Choose capabilities: ✅ **Voice**
4. Buy the number (~₹85/month for Indian numbers)
5. Copy your new phone number (e.g., +917012345678)

### Step 4: Configure CRM Environment

Add the following to your `.env` file:

```bash
# Twilio Click-to-Call Configuration
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+917012345678  # Your Twilio number

# Optional: Callback URL (auto-set by application)
TWILIO_CALLBACK_URL=https://your-crm-domain.com
```

### Step 5: Configure Twilio Webhooks

1. Go to Twilio Console → **Phone Numbers** → **Active Numbers**
2. Click on your purchased number
3. Scroll to **Voice & Fax** section
4. Set **A Call Comes In** to:
   - **Webhook**: `https://your-crm-domain.com/api/call/connect`
   - **HTTP Method**: POST
5. Set **Status Callback URL** to:
   - **Webhook**: `https://your-crm-domain.com/api/call/status`
   - **HTTP Method**: POST
6. Click **Save**

### Step 6: Update Database

Run the migration to update the CallLog table:

```bash
cd /home/user/webapp
flask db upgrade
```

Or manually run:

```bash
python -m flask db upgrade
```

### Step 7: Install Twilio SDK

```bash
cd /home/user/webapp
pip install twilio==8.10.0
```

### Step 8: Restart Application

```bash
# If using gunicorn
sudo systemctl restart your-crm-service

# If using systemd
sudo systemctl restart gaadicrm

# If running manually
python application.py
```

---

## 🎮 How to Use

### For Telecallers

1. Go to **Calling Queue** in CRM
2. View the current lead
3. Click **"Click-to-Call"** button
4. Wait for Twilio to call your phone (registered number)
5. Answer the call
6. You'll hear: "Connecting you to the customer. Please wait."
7. Customer's phone rings
8. When customer answers, you're connected!
9. After call ends, use Quick Log to update lead status

### Call Flow Diagram

```
┌─────────────┐
│  Telecaller │
│ Clicks Btn  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ Twilio Calls    │
│ Telecaller      │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Telecaller      │
│ Answers         │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Twilio Connects │
│ to Customer     │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Customer Answers│
│ Call Connected! │
└─────────────────┘
```

---

## 📊 Call Analytics

### View Call History

Access call logs for any lead:

```javascript
GET /api/call/history/{lead_id}
```

Response:
```json
{
  "success": true,
  "calls": [
    {
      "call_sid": "CA123...",
      "status": "completed",
      "duration": 125,
      "created_at": "2025-11-30T10:30:00",
      "user_name": "Rahul Kumar"
    }
  ]
}
```

### View Personal Call Stats

```javascript
GET /api/call/stats?from=2025-11-01&to=2025-11-30
```

Response:
```json
{
  "success": true,
  "stats": {
    "total_calls": 145,
    "completed_calls": 98,
    "failed_calls": 47,
    "success_rate": 67.6,
    "total_duration": 7250,
    "avg_duration": 73.98
  }
}
```

---

## 💰 Pricing (India)

### Twilio Costs

| Item | Cost (Approx) |
|------|---------------|
| Phone Number | ₹85/month |
| Outbound Call (per minute) | ₹0.60/min |
| Inbound Call (per minute) | ₹0.60/min |

### Example Monthly Cost

For 150 calls/day with 2 min average duration:

```
Calls per month: 150 calls/day × 22 days = 3,300 calls
Call minutes: 3,300 calls × 2 min/call = 6,600 minutes
Phone number: ₹85
Outbound (telecaller): 6,600 min × ₹0.60 = ₹3,960
Inbound (customer): 6,600 min × ₹0.60 = ₹3,960

Total: ₹85 + ₹3,960 + ₹3,960 = ₹8,005/month
```

**Per Call Cost**: ₹8,005 / 3,300 = **₹2.43 per call**

### ROI Analysis

**Savings from Click-to-Call:**
- Time saved per call: 25 seconds
- Calls per day: 150
- Time saved per day: 150 × 25 sec = 3,750 sec = **62.5 minutes**

**Value of time saved:**
- Additional calls possible: 62.5 min ÷ 3 min/call = **~20 extra calls/day**
- Revenue per call: ₹750 (assuming 10% conversion × ₹7,500 service)
- Additional revenue: 20 calls × ₹75 = **₹1,500/day**
- Monthly additional revenue: **₹33,000/month**

**Net Benefit**: ₹33,000 - ₹8,005 = **₹24,995/month profit**

---

## 🔧 Advanced Configuration

### Enable Call Recording

Add to `.env`:
```bash
TWILIO_RECORD_CALLS=true
```

Update the call initiation to include recording:

```python
call = client.calls.create(
    url=request.url_root + f'api/call/connect?customer={customer_mobile}&lead_id={lead_id}',
    to=user_mobile,
    from_=twilio_phone_number,
    record=True,  # Enable recording
    recording_status_callback=request.url_root + 'api/call/recording',
    status_callback=request.url_root + 'api/call/status'
)
```

### Set User Phone Numbers

If telecallers have different phone numbers than their usernames:

1. Add a `mobile` field to the User model
2. Update the API call to use user's mobile:

```javascript
fetch('/api/call/initiate', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        lead_id: leadId,
        customer_mobile: customerMobile,
        user_mobile: '9876543210'  // Telecaller's mobile
    })
});
```

### Customize Voice Messages

Edit the message in `/api/call/connect` route:

```python
response.say(
    'Connecting you to the customer. Please wait.',
    voice='alice',  # Options: 'alice', 'man', 'woman'
    language='en-IN'  # Options: 'en-IN', 'hi-IN'
)
```

For Hindi:
```python
response.say(
    'Kripya pratiksha karein. Aapko grahak se jod rahe hain.',
    voice='alice',
    language='hi-IN'
)
```

---

## 🐛 Troubleshooting

### Issue: "Twilio integration is not configured"

**Solution:**
1. Verify Twilio package is installed: `pip list | grep twilio`
2. Check `.env` file has all three variables set
3. Restart the application

### Issue: "Failed to initiate call"

**Possible Causes:**
1. **Invalid credentials** - Verify Account SID and Auth Token
2. **Insufficient funds** - Add credit to Twilio account
3. **Number not verified** (trial accounts) - Verify the telecaller's number in Twilio Console
4. **Incorrect phone format** - Ensure numbers include country code

**Check logs:**
```bash
tail -f /var/log/gaadicrm/application.log
```

### Issue: Call disconnects immediately

**Solution:**
1. Verify webhook URLs are publicly accessible
2. Check webhook URLs in Twilio Console are correct
3. Ensure SSL certificate is valid (webhooks require HTTPS)

### Issue: No call history showing

**Solution:**
1. Check database migration ran successfully
2. Verify CallLog table has new columns:
```sql
\d call_log
```

---

## 🔒 Security Best Practices

### 1. Validate Webhook Requests

Add Twilio signature validation:

```python
from twilio.request_validator import RequestValidator

@application.route('/api/call/status', methods=['POST'])
def call_status():
    # Validate request is from Twilio
    validator = RequestValidator(os.getenv('TWILIO_AUTH_TOKEN'))
    signature = request.headers.get('X-Twilio-Signature', '')
    
    if not validator.validate(request.url, request.form, signature):
        return jsonify({'error': 'Invalid signature'}), 403
    
    # Process webhook...
```

### 2. Rate Limiting

Current implementation limits to 60 calls per minute per user. Adjust if needed:

```python
@application.route('/api/call/initiate', methods=['POST'])
@login_required
@limiter.limit("60 per minute")  # Adjust this
def initiate_call():
```

### 3. Environment Variables

Never commit `.env` file to git. Add to `.gitignore`:

```bash
echo ".env" >> .gitignore
```

### 4. Restrict Access

Only allow Click-to-Call for authenticated telecallers:

```python
@application.route('/api/call/initiate', methods=['POST'])
@login_required  # Already implemented
def initiate_call():
    # Additional role check if needed
    if not current_user.is_telecaller:
        return jsonify({'error': 'Unauthorized'}), 403
```

---

## 📈 Monitoring & Analytics

### Dashboard Widgets

Add to analytics dashboard:

```html
<div class="card">
    <h5>Click-to-Call Stats</h5>
    <p>Total Calls: <strong id="total-calls">0</strong></p>
    <p>Success Rate: <strong id="success-rate">0%</strong></p>
    <p>Avg Duration: <strong id="avg-duration">0s</strong></p>
</div>

<script>
fetch('/api/call/stats')
    .then(r => r.json())
    .then(data => {
        document.getElementById('total-calls').textContent = data.stats.total_calls;
        document.getElementById('success-rate').textContent = data.stats.success_rate.toFixed(1) + '%';
        document.getElementById('avg-duration').textContent = data.stats.avg_duration + 's';
    });
</script>
```

### Export Call Reports

Add export endpoint:

```python
@application.route('/api/call/export', methods=['GET'])
@login_required
def export_calls():
    calls = CallLog.query.filter_by(user_id=current_user.id).all()
    # Generate CSV
    # Return file
```

---

## 🎓 Training for Telecallers

### Quick Start Guide

**Print this and give to each telecaller:**

1. **Login** to CRM
2. Go to **Calling Queue**
3. See current lead details
4. Click **"Click-to-Call"** button (blue button with phone icon)
5. **Your phone will ring** within 5 seconds
6. **Answer your phone**
7. You'll hear: "Connecting you to customer..."
8. **Customer's phone rings**
9. When customer answers, **start conversation**
10. After call ends, click **"Quick Log"** to update status

**Important Tips:**
- ✅ Keep your phone nearby
- ✅ Answer quickly when it rings
- ✅ Have headphones ready
- ✅ Update lead status immediately after call
- ❌ Don't click button multiple times
- ❌ Don't hang up before customer answers

---

## 📞 Support

### Twilio Support
- Help Center: https://support.twilio.com
- Phone: Available in Twilio Console
- Live Chat: Available for Pro+ accounts

### CRM Support
- Report issues to your CRM administrator
- Check application logs for errors
- Test with Twilio's test credentials first

---

## ✅ Checklist

Before going live, ensure:

- [ ] Twilio account created and verified
- [ ] Phone number purchased with voice capabilities
- [ ] All three environment variables set in `.env`
- [ ] Webhooks configured in Twilio Console
- [ ] Database migration completed
- [ ] Twilio package installed
- [ ] Application restarted
- [ ] Test call successful
- [ ] Telecallers trained
- [ ] Call logging verified
- [ ] Analytics working

---

## 🎉 Success Metrics

Track these KPIs after implementation:

| Metric | Before | Target | Actual |
|--------|--------|--------|--------|
| Calls per day | 70-80 | 150+ | ___ |
| Time per call | 3.5 min | 1 min | ___ |
| Lead coverage | 47-53% | 93-100% | ___ |
| Call success rate | - | 65%+ | ___ |
| Daily revenue | ₹5.6L | ₹15L+ | ___ |

---

**Last Updated**: November 30, 2025  
**Version**: 1.0  
**Author**: GaadiMech CRM Team
