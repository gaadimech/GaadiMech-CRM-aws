import datetime
import pytz

# Get the current datetime in UTC
now_utc = datetime.datetime.now(pytz.utc)

# Convert to IST
ist_timezone = pytz.timezone('Asia/Kolkata')
now_ist = now_utc.astimezone(ist_timezone)

print(now_ist)